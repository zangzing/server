module ZZ
  module Async

    class TestS3 < Base
      @queue = Priorities.queue_name('io', Priorities.test)

      # only add ourselves one time
      if @retry_criteria_checks.length == 0
        # plug ourselves into the retry framework
        retry_criteria_check do |exception, *args|
          self.should_retry exception, args
        end
      end

      def self.enqueue(test_id)
        super(test_id)
      end

      def self.perform(test_id)
#        puts "#{command} - #{iteration}"
        begin
          test = BenchTest::S3.find(test_id)

          test.start = DateTime.now
          test.result_message = "Test started."
          test.save!

          runner = S3TestRunner.factory(test)
          if test.upload
            runner.upload_test
          else
            runner.download_test
          end
          
          test.result_message = "Test complete."

        rescue Exception => ex
           test.result_message = "Test complete - failed with: " + ex.message

        ensure
          test.stop = DateTime.now
          test.save!
          runner.end_test
        end
      end

    end

    # this class runs the actual tests
    class S3TestRunner
      attr_accessor :s3_bucket, :file_name

      # make a single instance of the test runner
      def self.factory(test)
        runner = S3TestRunner.new()
        runner.init_test(test)
        runner
      end

      # cleanup to end test
      def end_test
        if @test_file
          File.delete(@test_file.path)
          PhotoGenHelper.s3.delete(self.s3_bucket, self.file_name)
        end
        @s3 = nil
        @test_file = nil
        @test = nil
      end

      # make a temporary test file for upload
      # note, we rely on the fact that S3 has already been
      # initialized with credentials at init time
      def init_test test
        @test = test
        file_size = @test.file_size
        self.file_name = "s3test-#{file_size.to_s}-#{rand(9999999999).to_s}"
        file_path = Dir.tmpdir + "/" + file_name
        block_size = 1024
        block_count = (file_size / block_size) + 1
        # quick way to make a large file by calling command line tool
        cmd = "dd if=/dev/zero of=#{file_path} bs=#{block_size} count=#{block_count} 2>/dev/null"
        # make the file
        `#{cmd}`

        # now open the file we just created
        @test_file = File.new(file_path, "rb")
        self.s3_bucket = "perftest.dev.zangzing"
      end

      # perform the upload test
      def upload_test
        iterations = @test.iterations
        for i in 1..iterations
          upload_one
        end
      end

      # upload a single file
      def upload_one
        # make sure file is at start
        @test_file.rewind
        PhotoGenHelper.s3.put(self.s3_bucket, self.file_name, @test_file)
        true
      end

      # perform the download test
      def download_test
        # need to ensure our file that we will be downloading is placed on s3
        upload_one

        iterations = @test.iterations
        for i in 1..iterations
          download_one
        end
      end

      # download a single file
      def download_one
        raw_data = PhotoGenHelper.s3.get(self.s3_bucket, self.file_name)
      end
    end

  end
end
