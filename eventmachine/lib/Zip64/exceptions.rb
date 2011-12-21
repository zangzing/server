module Zip64

class Zip64Error < StandardError; end
class AnotherFilePending < Zip64Error; end
class NotAllClosed < Zip64Error; end
class NoCurrentFile < Zip64Error; end
class SizeUnknown < Zip64Error; end

end # Zip64 module