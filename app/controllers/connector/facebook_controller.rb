class Connector::FacebookController < Connector::ConnectorController
  require 'hyper_graph'

  PHOTO_SIZES = {:thumb => 'a', :screen => 'n', :full => ['o', 'n']}

  before_filter :service_login_required

protected

  def service_login_required
        @graph ||= service_identity.facebook_graph
  end

  def service_identity
    @service_identity ||= current_user.identity_for_facebook
  end

  def facebook_graph
    @graph ||= service_identity.facebook_graph
  end


  def get_photo_url(photo_info, size)
    urls = photo_info[:images].map{|i| i[:source]}
    sz_letter = PHOTO_SIZES[size].is_a?(Array) ? "(#{PHOTO_SIZES[size].join('|')})" : PHOTO_SIZES[size]
    urls.select{|url| url =~ /_#{sz_letter}\.\w+$/ }.first
  end


end
