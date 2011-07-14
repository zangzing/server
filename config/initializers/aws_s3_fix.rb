module AWS
  module S3
    class Base
      class Response < String
        def error?
          return false if success?

          # ok, we have an error of some sort, if its one that we know how to parse just return true
          # to move onto the full error class generation
          return true if response['content-type'] == 'application/xml' && parsed.root == 'error'

          # it's still an error but we don't have any context so just throw a generic S3Exception
          raise S3Exception, "An unexpected Amazon API error occurred."
        end
      end
    end
  end
end
