class LogsController < ApplicationController
  
  def index
    logs = Dir.glob("#{RAILS_ROOT}/log/*.log").map { |logfile| File.basename(logfile, '.log') }
    response = logs.map { |logname| "<a href='#{log_retrieve_path(logname)}'>#{logname}</a>"  }.join('<br/>')
    render :text => response
  end
  
  def retrieve
    send_file "#{RAILS_ROOT}/log/#{params[:logname]}.log"
  end

end
