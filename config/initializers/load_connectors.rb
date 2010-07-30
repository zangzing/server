require 'flickraw'

require 'token_store'
require 'connector_exceptions'
include ZZ::Exceptions

Dir.glob('import_requests/*.rb'){ |f| require f }
#require 'lib/import_requests/flickr_import_request'
#require 'lib/import_requests/kodak_import_request'
require 'connectors/kodak_connector'
