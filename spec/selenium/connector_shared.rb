module ConnectorShared

  def begin_session!
    @browser_session = UiModel::SeleniumSession.new
    @browser_session.create_session!

    ui.open_site!
  end

  def end_session!
    @browser_session.close_session!
  end


  def join_as_new_user

    ui.toolbar.signin_drawer.join_tab.visible?.should be_true

    ui.toolbar.signin_drawer.join_tab.type_full_user_name current_user[:full_name]
    ui.toolbar.signin_drawer.join_tab.type_username current_user[:username]
    ui.toolbar.signin_drawer.join_tab.type_email current_user[:email]
    ui.toolbar.signin_drawer.join_tab.type_password current_user[:password]
    ui.toolbar.signin_drawer.join_tab.click_join_button
    ui.user_homepage.close_welcome_div

    ui.toolbar.signed_in_as?(current_user[:full_name]).should be_true
  end

  def create_new_album    #(type)
    ui.toolbar.click_create_album
 #   ui.wizard.album_type_tab.visible?.should be_true
 #   ui.wizard.album_type_tab.send("click_#{type}_album".to_sym)
    ui.wizard.add_photos_tab.visible?.should be_true
  end

  def connect_to_service(service, filechooser_folder_name)
    ui.wizard.add_photos_tab.at_home?.should be_true
    ui.wizard.add_photos_tab.click_folder filechooser_folder_name
    ui.wizard.add_photos_tab.click_connect
    ui.oauth_manager.send("login_to_#{service}".to_sym);
  end

  def import_random_photos(amount, go_up_after = true)
    ui.wizard.add_photos_tab.add_random_photos(amount)
    ui.wizard.add_photos_tab.back_level_up if go_up_after
  end

  def click_import_all_photos
    ui.wizard.add_photos_tab.at_home?.should_not be_true
    ui.wizard.add_photos_tab.click_all_photos####################################################
  end

  def set_album_name(name)
    ui.wizard.click_name_tab
    ui.wizard.album_name_tab.visible?.should be_true
    ui.wizard.album_name_tab.type_album_name name

  end

  def close_wizard
    ui.wizard.click_share_tab
    ui.wizard.click_done
    ui.wait_load
  end

  def get_photos_from_added_album(album_name)
    ui.toolbar.click_zz_logo
    ui.wait_load
    ui.user_homepage.inside_album_list?.should be_true
    albums = ui.user_homepage.get_album_list
    albums.include?(album_name).should be_true

    ui.user_homepage.click_album album_name
    ui.user_homepage.inside_album?.should be_true

    ui.user_homepage.get_photos_list
  end

end