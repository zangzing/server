# utility class that provides support for passing args across app servers from main app server to thin eventmachine
class EventMachineRPC
  unless defined?(JSON_IPC_PATH)
    JSON_IPC_PATH = '/data/tmp/json_ipc'.freeze
  end

  # reads the json from the file given
  # and removes the file
  # limit to the JSON_IPC_PATH dir
  # returns in symbolized form
  def self.parse_json_from_file(path)
    return {} if path.nil? || File.expand_path(path).index(JSON_IPC_PATH) != 0
    json_str = File.read(path) rescue nil
#TODO uncomment delete below after testing
#    File.delete(path) rescue nil unless safe_rails_env == 'development'

    args = JSON.parse(json_str) rescue {}
    Hash.recursively_symbolize_graph!(args)
  end

  # given a jsonable argument, generate
  # a suitable file in the temp dir that contains
  # the json to be used to pass data across process
  def self.generate_json_file(data)
    json_str = JSON.fast_generate(data)
    filename = "/data/tmp/json_ipc/#{Process.pid}.#{Time.now.to_f}.#{rand(9999999999)}.json"
    File.open(filename, 'w') {|f| f.write(json_str) }
    filename
  end

  def self.file_crc32(path)
    json_str = File.read(path)
    crc32 = Zlib.crc32(json_str, 0)
  end
end