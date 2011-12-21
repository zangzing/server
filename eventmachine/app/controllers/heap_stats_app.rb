class HeapStatsApp < AppBase

  # /heap
  def heap(env)
    body = HeapTracker.current_instance.gc_stats
    header = {
        'Content-Type' => 'text/html',
        'Cache-Control' => 'no-cache',
    }

    [200, header, [body]]
  end

  # /heap_track
  def heap_track(env)
    track_on = ZZUtils.as_boolean(json_data[:on])
    if track_on
      HeapTracker.current_instance.track(true)
      body = "Memory Tracking on"
    else
      HeapTracker.current_instance.track(false)
      body = "Memory Tracking off"
    end

    header = {
        'Content-Type' => 'text/plain',
        'Cache-Control' => 'no-cache',
    }
    [200, header, [body]]
  end
end

