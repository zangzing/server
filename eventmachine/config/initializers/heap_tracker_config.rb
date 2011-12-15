require 'heap_tracker'

# pull in the heap tracker rack add on
HeapTracker.load_config(File.dirname(__FILE__) + "/../async_config.yml")
HeapTracker.tracking_allowed = true