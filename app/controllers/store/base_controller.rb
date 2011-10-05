class Store::BaseController < ApplicationController
  before_filter :require_user, :require_admin


end