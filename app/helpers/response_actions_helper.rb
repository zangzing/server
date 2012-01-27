module ResponseActionsHelper

  def perform_render_actions
      perform_response_actions( :ractions )
  end

  def perform_javascript_actions
      perform_response_actions( :jsactions )
  end


  def add_javascript_action( action_name, args_hash = {} )
    args_hash[:method] = action_name
    ( session[:jsactions] ||=  [] ) << args_hash
  end

  def add_render_action( action_name, args_hash = {} )
      args_hash[:method] = action_name
      ( session[:ractions] ||=  [] ) << args_hash
  end

  protected
  # session render actions are hashes which include
  # at least :method => action_method_name and keys for the
  # action arguments if any.
  def perform_response_actions( key )
    response = []

    # Look in the session first then in the params
    #[session,params].each do |hash|
    [session].each do |hash|
      if hash[ key ]
        hash[key].each do | action |
          if action[:method]
            method_name =  "#{(key == :ractions ? 'render_' :'js_')}#{action[:method]}"
            if self.respond_to?(method_name)
              response << self.send( method_name,  action)
            else
              hash.delete( key )
              raise Exception.new('Unknown Response Action method_name: '+method_name)
            end
          end
        end
        hash.delete( key )
      end
    end
    response.join("\n")
  end

  def js_show_welcome_dialog( action )
    %{ zz.welcome.show_welcome_dialog(); }
  end

  def js_show_message_dialog( action )
    raise Exception.new( 'jsaction show_message_dialog  contains no message') unless action[:message]
    %{ zz.dialog.show_flash_dialog('#{escape_javascript action[:message]}'); }
  end

  def js_show_add_photos_dialog( action )
    %{ zz.photochooser.open_in_dialog(zz.page.album_id, function() {
            window.location.reload(false);
        });
      }
  end

  def js_send_zza_event_from_client( action )
    raise Exception.new('jsaction send_zza_events_from_client  contains no event') unless action[:event]
    %{ ZZAt.track('#{ escape_javascript action[:event].to_s }'); }
  end

  def js_show_album_wizard( action )
    raise Exception.new('Must specify a wizard step') unless action[:step]
    case action[:step]
      when "group" then
        mail = (action[:email]? action[:email]:'')
        s = %{ zz.wizard.open_group_tab('#{escape_javascript mail.to_s }'); }
      else
        raise Exception.new("#{action[:step]} not implemented in response actions helper yet")
    end
    s
  end

  def js_show_request_access_dialog( action )
      raise Exception.new('jsaction request_access_dialog  contains no album_id') unless action[:album_id]
      %{ zz.dialog.show_request_access_dialog('#{escape_javascript action[:album_id].to_s}'); }
  end

  def js_show_request_contributor_dialog( action )
    raise Exception.new('jsaction request_contributor_dialog  contains no album_id') unless  action[:album_id]
    %{ zz.dialog.show_request_contributor_dialog('#{escape_javascript action[:album_id].to_s}'); }
  end

  def js_show_import_all_dialog(action)
     "zz.import_albums.show_import_dialog();"
  end

  #def render_show_request_access_dialog( action )
  #  raise Exception.new('raction request_access_dialog  contains no album_id') unless action[:album_id]
  #  render :partial => 'albums/pwd_dialog',:locals => {:album_id => action[:album_id]}
  #end

  #def render_show_request_contributor_dialog( action )
  #  raise Exception.new('raction request_contributor_dialog  contains no album_id') unless  action[:album_id]
  #  render :partial => 'albums/contributor_dialog',:locals => {:album_id => action[:album_id]}
  #end
end