# this was derived from
# https://github.com/cheald/scrap
# and modified to work in rails 3
#
class HeapTracker
  unless defined?(COMMIFY_REGEX)
    COMMIFY_REGEX = /(\d)(?=(\d\d\d)+(?!\d))/
    CRLF = "\r\n"
  end

	@@gc_stats = {}
	@@last_gc_run = nil
	@@last_gc_mem = nil
	@@requests_processed = 0
	@@request_list = []
	@@alive_at = nil
	@@gc_stats_enabled = nil
  @@tracking_allowed = false  # default to off
	@@config = nil

  def self.load_config(path)
    @@config ||= YAML::load open(path).read
  end

  def initialize(app)
    @app = app
    @@current_instance = self
    config
  end

  def self.current_instance
    @@current_instance
  end

  def self.tracking_allowed=(allowed)
    @@tracking_allowed = allowed
  end

  def self.tracking_allowed
    @@tracking_allowed
  end

	def config
		if @@config.nil?
      HeapTracker.load_config(File.join(Rails.root, "config", "heap_tracker.yml"))
    end
    @@config
	rescue Errno::ENOENT
		@@config = {}
	rescue
		puts "[heap_tracker] heap_tracker.yml: #{$!.message}"
		@@config = {}
	end

  def track(tracking)
    @@tracking = tracking
  end

	def call(env)
    if @@tracking_allowed
      if !@@gc_stats_enabled then
        GC.enable_stats if GC.respond_to? :enable_stats
        @@gc_stats_enabled = true
      end
      @@requests_processed += 1
      @@last_gc_run ||= @@alive_at ||= Time.now.to_f
      @@last_gc_mem ||= get_usage

      req = sprintf("<p>[%-10.2fMB] %s %s</p>", get_usage, env["REQUEST_METHOD"], env["PATH_INFO"])
      req << "<pre>#{ObjectSpace.statistics}</pre>" if ObjectSpace.respond_to? :statistics
      @@request_list.unshift req
      @@request_list.pop if @@request_list.length > (config["max_requests"] || 150)
    end
    @app.call(env)
	end

	def gc_stats
    return '' unless @@tracking_allowed
		collected = nil
		#puts "Respond to? #{ObjectSpace.respond_to? :live_objects}"
		if ObjectSpace.respond_to? :live_objects then
			live = ObjectSpace.live_objects
			GC.start
			collected = live - ObjectSpace.live_objects
		else
			GC.start
		end
		GC.start
		usage = get_usage

		mem_delta = usage - @@last_gc_mem
		time_delta = Time.now.to_f - @@last_gc_run
		s = ''
		s << '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"' << CRLF
		s << '   "http://www.w3.org/TR/html4/strict.dtd">' << CRLF
		s << '<html><head>' << CRLF
		s << "<title>[#{$$}] Garbage Report</title>" << CRLF
		s << '<style type="text/css"> body { font-family: monospace; color: #222; } td { border-bottom: 1px solid #eee; padding: 1px 9px; } td.t { background: #fafafa; } tr:hover td { background: #fafaf0; border-color: #e0e0dd; } h1,h2,h3 { border-bottom: 1px solid #ddd; font-family: sans-serif; } </style>' << CRLF
		s << '<body>' << CRLF

		s << "<h1>Heap - PID #{$$}</h1>" << CRLF

		s << '<table>' << CRLF
		s << sprintf('<tr><td class="t">Memory usage:</td><td>%2.2fMB</td></tr>', usage)
		s << sprintf('<tr><td class="t">Delta:</td><td>%2.2fMB</td></tr>', mem_delta)
		s << sprintf('<tr><td class="t">Last Heap req:</td><td>%2.2f seconds ago</td></tr>', time_delta)
		s << sprintf('<tr><td class="t">Requests processed:</td><td>%s</td></tr>', @@requests_processed)
		s << sprintf('<tr><td class="t">Alive for:</td><td>%2.2f seconds</td></tr>', Time.now.to_f - @@alive_at)
		if GC.respond_to? :time then
			s << sprintf('<tr><td class="t">Time spent in GC:</td><td>%2.2f seconds</td></tr>', GC.time / 1000000.0)
		end
		if collected
			s << sprintf('<tr><td class="t">Collected objects:</td><td>%2d</td></tr>', collected)
			s << sprintf('<tr><td class="t">Live objects:</td><td>%2d</td></tr>', ObjectSpace.live_objects)
		end
		s << '</table>' << CRLF

		s << "<h3>Top #{config["max_objects"]} deltas since last request</h3>"
		s << '<table border="0">'
		memcheck(config["max_objects"], Object, :deltas).each do |v|
			next if v.last == 0
			s << "<tr><td class='t'>#{v.first}</td><td>#{sprintf("%s%s", v.last >= 0 ? "+" : "-", commify(v.last))}</td></tr>"
		end
		s << '</table>'

		s << "<h3>Top #{config["max_objects"]} objects</h3>"
		s << '<table border="0">'
		memcheck(config["max_objects"]).each do |v|
			s << "<tr><td class='t'>#{v.first}</td><td>#{commify v.last}</td></tr>"
		end
		s << '</table>'

		#(config["classes"] || {}).each do |klass, val|
		#	puts val.inspect
		#	opts = val === true ? {"print_objects" => true} : val
		#	add_os(klass.constantize, s, opts)
		#end

		s << '<h3>Request history</h3>'
		@@request_list.each do |req|
			s << req
		end
		s << '</body></html>'

		@@last_gc_run = Time.now.to_f
		@@last_gc_mem = usage
		@@requests_processed = 0
    s
	end

	def get_usage
		usage = 0
		begin
			usage = `cat /proc/#{$$}/stat`.split(" ")[22].to_i / (1024 * 1024).to_f
		rescue
			# pass
		end
		return usage
	end

	def add_os(c, s, options = {})
		print_objects = options["print_objects"]
		small = options["small"]
		min = options["min"]
		show_fields = options["show_fields"]

		ct = ObjectSpace.each_object(c) {}
		return if min and ct < min

		if small
			s << "#{c} (#{ct})<br />"
		else
			s << "<h3>#{c} (#{ct})</h3>"
		end

		return if !print_objects or ct == 0
		s << CRLF
		s << '<table>'
		val = ObjectSpace.each_object(c) do |m|
			s << '<tr><td class="t">' << "&lt;#{m.class.to_s}:#{sprintf("0x%.8x", m.object_id)}&gt;</td>"
			if show_fields then
				show_fields.each do |field|
					v = m.attributes[field.to_s]
					if v.blank?
						s << '<td>&nbsp;</td>'
					else
						s << "<td>#{field}: #{v}</td>"
					end
				end
			end
			s << '</tr>'
		end
		s << '</table>' << CRLF
	end

	def memcheck(top, klass = Object, mode = :normal)
		top ||= 50
		os = Hash.new(0)
		ObjectSpace.each_object(klass) do |o|
			begin;
				# If this is true, it's an association proxy, and we don't want to invoke method_missing on it,
				# as it will result in a load of the association proxy from the DB, doing extra DB work and
				# potentially creating a lot of AR objects. Hackalicious.
				next if o.respond_to? :proxy_respond_to?
				os[o.class.to_s] += 1 if o.respond_to? :class
			rescue; end
		end
		if mode == :deltas then
			os2 = Hash.new(0)
			os.each do |k, v|
				os2[k] = v - (@@gc_stats[k] || 0)
				@@gc_stats[k] = v
			end
			sorted = os2.sort_by{|k,v| -v }.first(top)
		else
			sorted = os.sort_by{|k,v| -v }.first(top)
		end
	end

	def commify(i)
		i.to_s.gsub(COMMIFY_REGEX, "\\1,")
	end
end
