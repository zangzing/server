class AgentsController < ApplicationController
  before_filter :oauth_required

  def index
    @agents = Agent.find_all_by_user_id(current_user.id, :conditions => 'oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null')
  end

  def info
    render :json=> "Statistics received. Thank you", :status=>200 and return #TODO:Do something with the statistics
  end

  def check
    render :json => "ERROR: Version argument missing" ,:status => 400 and return unless params[:version]
    render :json => "ERROR: Platform argument missing", :status => 400 and return unless params[:platform]
    render :json => "ERROR: Platform Version argument missing", :status => 400 and return unless params[:platform_version]

    response ={}


    if( rand(1000) > 500  )
      response[:version]    = "OK"
    else
      response[:version]    = "update"
      response[:update_type] = ( rand(1000) > 500 ? "optional" : "required" )
      response[:url]         = "http://www.zangzing.com/#{params[:platform]}/1/ZangZing-Setup-v#{ Faker::PhoneNumber.phone_number}.exe"
	    response[:url_readme]  =	"http://www.zangzing.com/#{params[:platform]}/1/readme.html"
	    response[:message]     = "Download this version to fix: #{Faker::Company.catch_phrase}"
    end

    render :json => response;
  end
end
