class AsyncResponsesController < ApplicationController

  def show
    body = AsyncResponse.get_response(params[:response_id])

    if body.nil?
      response.headers["x-poll-for-response"] = async_response_url(params[:response_id])
      render :json => {:message => "poll-for-response"}
    else
      puts body
      if body.starts_with? '{"error":'
        #don't parse json until we know we need to
        error = JSON.parse(body)
        response.headers["x-asyng-error-code"] = error["error"]["code"].to_s
        response.headers["x-asyng-error-message"] = error["error"]["message"].to_s
        render :json => body, :status => 500
      else
        expires_in 1.day, :public => false
        render :json => body
      end
    end
  end
end
