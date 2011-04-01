class AsyncResponsesController < ApplicationController
  def show
    response = AsynchResponse.get_response(params[:response_id])
=begin
    if response.nil?
      response.headers["X-Poll-for-response"] = asynch_response_url(params[:response_id])
      render :nothing => true
      return
    end
=end
    render :json => response
  end
end
