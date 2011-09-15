class Moderator::BaseController < ApplicationController
  before_filter :require_user, :require_admin

  def index
    redirect_to moderator_upload_batches_path
  end

end
