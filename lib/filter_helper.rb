# this class supports a simple filtering mechanism
# that can be used to build sets of allowed or excluded operations
# it expects a hash in the following form:
#
# {} or nil, means allow all
# {
#   :only => [str1, str2]
# }
# Above allows just str1 and str2
#
# {
#   :except => [str4, str5]
# }
# Above allows all except for str4 and str5
#
class FilterHelper
  def initialize(options = nil)
    if options.nil? || options.empty?
      @all = true
    else
      raise ArgumentError, "Options must include only one choice, :only, or :except" if options.length > 1
      only = options[:only]
      except = options[:except]
      raise ArgumentError, "Option must be either :only, or :except" if only.nil? && except.nil?

      @all = false
      if only.nil? == false
        # set up for only list
        raise ArgumentError, ":only must be an array" unless only.is_a?(Array)
        @only = only
      else
        # set up for except list
        raise ArgumentError, ":except must be an array" unless except.is_a?(Array)
        @except = except
      end
    end
  end

  # checks to see if the item is allowed
  def allow?(item)
    return true if @all

    if @only.nil? == false
      # only filter
      allowed = @only.include?(item)
    else
      # except filter - note that we invert the includes with ! since we
      # are allowed when not included in the except list
      allowed = !@except.include?(item)
    end

    allowed
  end
end