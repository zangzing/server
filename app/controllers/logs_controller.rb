class LogsController < ApplicationController
  require "base64"

  def index
    logs = Dir.glob("#{RAILS_ROOT}/log/*.log").map { |logfile| File.basename(logfile) }
    response = logs.map { |logname| "<a href='#{log_retrieve_path(Base64.encode64(logname))}'>#{logname.gsub('.log', '')}</a>"  }.join('<br/>')
    render :text => response
  end
  
  def retrieve
    send_file "#{RAILS_ROOT}/log/#{Base64.decode64(params[:logname])}"
  end

end
