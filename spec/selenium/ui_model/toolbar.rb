module UiModel

  class Toolbar
    attr_reader :signin_drawer

    def initialize(selenuim_session)
      @session = selenuim_session
      @browser = selenuim_session.browser

      @signin_drawer = SigninDrawer::Drawer.new(selenuim_session)
    end

#    def open_sign_in_drawer
#      @browser.click "css=#sign-in-button"
#      @session.wait_for "css=#step-join-off"
#    end

    def signed_in_as?(user)
      puts @browser.get_text("css=#user-info > h2")
      @browser.get_text("css=#user-info > h2").casecmp(user)==0
    end

    def click_create_album
      @browser.click "css=#new-album-button"
      @session.wait_for "css=#group_album_link"
    end

    def click_zz_logo
      @browser.click "css=#home-button"
    end

    def click_contributors
      @browser.click "css=#people-view-button"
      @session.wait_for "css=#album-timeline"
    end
  end

end