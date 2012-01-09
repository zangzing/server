# this class tracks any zz api error condition set
class ZZAPIError < StandardError
  attr_reader :result, :code

  # the message here can be a string, array or hash
  # for consistency you should generally use a single string,
  # an array of strings or as last resort a custom hash
  def initialize(result, code = 409)
    @result = result
    @code = code
  end

  def to_s
    if @result.is_a?(String)
      @result
    else
      super
    end
  end
end


#begin
#  raise ZZAPIError.new({:test=>"data", :arr=>[1,2,3]})
#rescue ZZAPIError => ex
#  ex.message
#  ex.to_s
#  puts ex.result.to_s
#  puts ex.code
#end