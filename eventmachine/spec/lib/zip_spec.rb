require "rspec_helper"

# helper class for testing
class OutStream
  # creates a temp file to write into
  def initialize(path)
    File.delete(path) rescue nil
    @temp_file = File.new(path, 'wb+')
  end

  def close
    @temp_file.close
  end

  def write(chunk)
    @temp_file.write(chunk)
  end

  def path
    @temp_file.path
  end

  def delete
    @temp_file.delete
  end
end

describe "Zip writer" do
  before(:each) do
    @out_stream = OutStream.new('/data/tmp/zip-test.zip')
  end

  def read_file(path)
    data = File.open(path, 'rb') { |f| f.read }
    crc32 = Zlib.crc32(data, 0)
    data
  end

  def test_data
    @test_data ||= "tdata1" * 4
    #@test_data ||= read_file('/Users/gseitz/Develop/zz/file3.jpg')
  end

  def test_data2
    @test_data2 ||= "tdata2" * 4
    #@test_data2 ||= read_file('/Users/gseitz/Develop/zz/file2.jpg')
  end

  def make_test_hash(count, calc_crc)
    urls = []
    count.times do |i|
      suffix = "-%05d" % i + ".txt"
      data = "hello#{suffix}"
      crc32 = calc_crc ? Zlib.crc32(data, 0) : nil
      urls << { :url => "http://nothing", :data => data, :size => data.bytesize, :crc32 => crc32, :create_date => nil, :filename => "file#{suffix}"}
    end
    urls
  end

  it "should validate arguments" do
    @mgr = Zip64::WriteManager.new(@out_stream)
    lambda {
      @mgr.push_data(test_data)
    }.should raise_error(Zip64::NoCurrentFile)

    @mgr.start_file("test1", test_data.bytesize, nil, Time.now)
    lambda {
      @mgr.start_file("test1", test_data.bytesize, nil, Time.now)
    }.should raise_error(Zip64::AnotherFilePending)

    lambda {
      @mgr.finish_all
    }.should raise_error(Zip64::NotAllClosed)
  end

  def push_file(name, data, crc32, time = Time.now)
    @mgr.start_file(name, data.bytesize, crc32, time)
    @mgr.push_data(data)
    @mgr.finish_file
  end

  def push_file_crc(name, data, time = Time.now)
    crc32 = Zlib.crc32(data, 0)
    puts "Checksum for #{name} is #{crc32.to_s(16)}"
    push_file(name, data, crc32, time)
  end

  it "should push a file entry" do

    @mgr = Zip64::WriteManager.new(@out_stream)

    push_file_crc("test1.txt", "abcd")
    push_file_crc("test2.txt", "efgh")

    #push_file_crc("test1.jpg", test_data2)
    #
    #push_file_crc("test2.jpg", test_data)
    #
    #push_file_crc("漢字test3漢字3.jpg", test_data)
    #
    #push_file_crc("漢字test4漢字4.jpg", test_data2)

    @mgr.finish_all
    puts @out_stream.path
    #@out_stream.delete
    #`scp -i ~/.ssh/amazon_staging.pem  /Users/gseitz/Develop/zz/zip-test.zip ec2-user@ec2-184-72-155-201.compute-1.amazonaws.com:/home/ec2-user`
  end

  it "should generate proper zip size with crc32" do
    urls = make_test_hash(2, true)
    total_data = 0
    urls.each do |url|
      total_data += url[:size]
    end
    zip_size, data_size, signature, supports_seek = Zip64::WriteManager.compute_zip_size(urls)
    supports_seek.should == true
    data_size.should == total_data
    signature.should == "2521cbe52613af9d579b20865c1cd1c0741a5770"
    zip_size.should == 260
  end

  it "should generate proper zip stubs and compare to zip file size" do
    urls = make_test_hash(2, false)
    total_data = 0
    urls.each do |url|
      total_data += url[:size]
    end
    zip_size, data_size, signature, supports_seek = Zip64::WriteManager.compute_zip_size(urls)
    supports_seek.should == false
    data_size.should == total_data
    signature.should == "3aa6da290ce6d12bd2bd4810097bd9d38fe862bb"
    zip_size.should == 292

    # now write a real file and verify
    path = "/data/tmp/zip_size_test.zip"
    out = OutStream.new(path)
    @mgr = Zip64::WriteManager.new(out, total_data)
    urls.each do |url|
      push_file(url[:filename], url[:data], url[:crc32])
    end
    @mgr.finish_all
    # get the file size from the path
    zip_file_size = File.size(path)
    zip_file_size.should == zip_size
  end

  it "should generate proper zip64 file size" do
    urls = make_test_hash(2, false)
    total_data = 0
    urls.each do |url|
      # no size will cause zip64 to be created
      url[:size] = nil
    end
    zip_size, data_size, signature, supports_seek = Zip64::WriteManager.compute_zip_size(urls)
    supports_seek.should == false
    data_size.should == nil
    signature.should == "987d9aad8bc26cbee2c811d1a41413ab89c95164"
    zip_size.should == nil
  end

  it "should only output partial zip file" do
    urls = make_test_hash(2, false)
    total_data = 0
    urls.each do |url|
      total_data += url[:size]
    end
    zip_size, data_size, signature, supports_seek = Zip64::WriteManager.compute_zip_size(urls)
    supports_seek.should == false
    data_size.should == total_data
    signature.should == "3aa6da290ce6d12bd2bd4810097bd9d38fe862bb"
    zip_size.should == 292

    # now write a real file and verify
    offset = 100
    expected_size = zip_size - offset
    path = "/data/tmp/zip_size_test.zip"
    out = OutStream.new(path)
    @mgr = Zip64::WriteManager.new(out, total_data, offset)
    urls.each do |url|
      push_file(url[:filename], url[:data], url[:crc32])
    end
    @mgr.finish_all
    # get the file size from the path
    zip_file_size = File.size(path)
    zip_file_size.should == expected_size
  end

  # handy commands
  # show connections on given ports
  # lsof -i -P | grep -i ":80\|:3001"
  #
end