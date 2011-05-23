class Admin::LogsController < Admin::AdminController
  require "base64"
  ssl_allowed :index


  def index
      @logs = Dir.glob("#{Rails.root}/log/*.log").map { |logfile| File.basename(logfile) }
      @page = 'logs'
  end
  
  def retrieve
      #send_file "#{Rails.root}/log/#{Base64.decode64(params[:logname])}", :type => 'text/plain'
      render :file => "#{Rails.root}/log/#{Base64.decode64(params[:logname])}",
             :layout =>false,
             :content_type => 'text/plain'
  end


end
