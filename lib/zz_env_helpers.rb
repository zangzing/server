# return a small back trace limited to
# limit specified or 5 lines by default
# also adds exception message at top
def small_back_trace(ex, lines = 5)
  result = ex.message + "\n"
  bt = ex.backtrace
  lines_left = lines
  bt.each do |line|
    if (lines_left > 0)
      result << line + "\n"
    end
    lines_left -= 1
  end

  return result
end