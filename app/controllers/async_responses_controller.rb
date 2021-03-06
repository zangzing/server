class AsyncResponsesController < ApplicationController

  def show
    body = AsyncResponse.get_response(params[:response_id])

    if body.nil?
      response.headers["x-poll-for-response"] = async_response_url(params[:response_id])
      render :json => {:message => "poll-for-response"}
    elsif !body.is_a?(Array) && /"exception"\s*:\s*true/ =~ body  #todo: Oleg added the Array check for the dropbox connector. not sure why
      exception_info = JSON.parse(body)
      render :json => {:message => exception_info['message']}, :status => exception_info['code']
    else
#      expires_in 1.day, :public => false
      render :json => body
    end
  end

end
