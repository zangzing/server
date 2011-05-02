class Connector::FacebookController < Connector::ConnectorController
  require 'hyper_graph'

  PHOTO_SIZES = {:thumb => 'a', :screen => 'n', :full => ['o', 'n']}

  def self.api_from_identity(identity)
    if identity.is_a?(FacebookIdentity)
      identity.facebook_graph
    else
      nil
    end
  end

  def self.moderate_exception(exception)
    if exception.kind_of?(FacebookError) && exception.message.include?('OAuth') then
      InvalidToken.new(exception.message)
    end
  end

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


  def self.get_photo_url(photo_info, size)
    images = photo_info[:images]
    sz_letter = PHOTO_SIZES[size].is_a?(Array) ? "(#{PHOTO_SIZES[size].join('|')})" : PHOTO_SIZES[size]
    result = images.select{|img| img[:source] =~ /_#{sz_letter}\.\w+$/ }.first
    unless result #In case of new url scheme or other failure
      images.sort_by { |img| img[:width].to_i * img[:height].to_i } #Larger are first
      result = case size
      when :thumb then images[-2] #Last image has too poor resolution, so we'll pick second from the end
      when :screen then images[-4] || images.first
      when :full then images.first #Either original or largest of available
      end
    end
    result[:source]
  end
  
  def self.make_source_guid(photo_info)
    "facebook_"+Photo.generate_source_guid(photo_info[:source])
  end


end
