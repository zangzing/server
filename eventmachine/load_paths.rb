# set up load paths and do requires for all


# add the array of sub dirs to the load path
def prepend_load_path(sub_dirs)
  priority = sub_dirs.reverse
  priority.each do |sub_dir|
    path = File.expand_path(File.join(File.dirname(__FILE__), sub_dir))
    #puts path
    $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
  end
end

