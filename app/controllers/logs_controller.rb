class LogsController < ApplicationController
  require "base64"

  def index
    unless Rails.env.production? 
      logs = Dir.glob("#{RAILS_ROOT}/log/*.log").map { |logfile| File.basename(logfile) }
      response = logs.map { |logname| "<a href='#{log_retrieve_path(Base64.encode64(logname))}'>#{logname.gsub('.log', '')}</a>"  }.join('<br/>')
      render :text => response
    end
  end
  
  def retrieve
    unless Rails.env.production?
      send_file "#{RAILS_ROOT}/log/#{Base64.decode64(params[:logname])}"
    end
  end

end
