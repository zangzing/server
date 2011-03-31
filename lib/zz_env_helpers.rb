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

# return a safe default if nil
def safe_default(item, default)
  item.nil? ? default : item
end

# return the default if the map does not exist, or the
# map[key] element does not exist
def safe_hash_default(map, key, default)
  value = map.nil? ? default : map[key]
  safe_default(value, default)
end

