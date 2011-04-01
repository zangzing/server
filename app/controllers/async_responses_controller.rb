class AsyncResponsesController < ApplicationController
  def show
    body = AsyncResponse.get_response(params[:response_id])

    if body.nil?
      response.headers["x-poll-for-response"] = async_response_url(params[:response_id])
      render :json => {:message => "poll-for-response"}
    else
      render :json => body
    end
  end
end
