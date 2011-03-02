module UimodelHelper

  def ui
    @browser_session
  end

  def generate_user_info
    stamp = Time.now.to_i.to_s(30).upcase
    {
      :full_name => "AutoTest #{stamp}",
      :username => "user#{stamp.downcase}",
      :password => '123456',
      :email => "selenium_#{stamp}@bucket.zangzing.com",
      :stamp => stamp
    }
  end
  
  def current_user
    @current_test_user ||= generate_user_info
  end

  #Not used now -- need to decide if we'll use single user
  def join_user
    ui.toolbar.open_sign_in_drawer
    ui.toolbar.signin_drawer.click_join_tab
    ui.toolbar.signin_drawer.join_tab.type_full_user_name UiModel::TEST_USER[:full_name]
    ui.toolbar.signin_drawer.join_tab.type_username UiModel::TEST_USER[:username]
    ui.toolbar.signin_drawer.join_tab.type_email UiModel::TEST_USER[:email]
    ui.toolbar.signin_drawer.join_tab.type_password UiModel::TEST_USER[:password]
    ui.toolbar.signin_drawer.join_tab.click_join_button
  end

  def sign_user_in
    ui.toolbar.open_sign_in_drawer
    ui.toolbar.signin_drawer.click_signin_tab
    ui.toolbar.signin_drawer.signin_tab.type_email UiModel::TEST_USER[:email]
    ui.toolbar.signin_drawer.signin_tab.type_password UiModel::TEST_USER[:password]
    ui.toolbar.signin_drawer.signin_tab.click_signin_button
  end

end