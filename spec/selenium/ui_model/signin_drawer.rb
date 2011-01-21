module UiModel
  module SigninDrawer

    class Drawer
      attr_reader :signin_tab, :join_tab

      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser

        @join_tab = JoinTab.new(selenuim_session)
        @signin_tab = SigninTab.new(selenuim_session)
      end

      def click_join_tab
        @browser.click "css=#step-join-off"
        @session.wait_for "css=#user_name"
      end

      def click_signin_tab
      end
    end

    class SigninTab
      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser
      end
    end

    class JoinTab

      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser
      end

      def type_full_user_name first_last_name
        @browser.type "css=#user_name", first_last_name
      end

      def type_username username
        @browser.type "css=#user_username", username
      end

      def type_email email
        @browser.type "css=#user_email", email
      end

      def type_password password
        @browser.type "css=#user_password", password
      end

      def click_join_button
        @browser.click "css=#join_form_submit_button"
        @browser.wait_for_page_to_load "30000"
      end
    end

  end
end