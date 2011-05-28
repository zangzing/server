module UiModel
  module SettingsTab
    class Drawer
      attr_reader :password_tab
      def initialize(selenuim_session)
        @session = selenuim_session
        @browser = selenuim_session.browser

        @password_tab = PasswordTab.new(selenuim_session)
      end


      def type_first_name fname
        @browser.type "css=input#user_first_name", fname
      end

      def type_last_name lname
        @browser.type "css=input#user_last_name", lname
      end

      def type_email email
        @browser.type "css=#user_email", email
      end

      def click_done
        @browser.click "css=a.green-button.done-button"
        @session.wait_load
      end

      def click_change_password
        @browser.click "css=a#change-password-button"
        @session.wait_load
      end
    end

    class PasswordTab
      def type_old_password  old_passwd
        @browser.type "css=input#user_old_password", old_passwd
      end

      def type_new_password  new_passwd
        @browser.type "css=input#user_password", new_passwd
      end

      def type_new_password_confirm new_passwd_confirm
        @browser.type "css=input#user_password_confirmation", new_passwd_confirm
      end

      def click_done
        @browser.click "css=a#pass-done-button.green-button.done-button"
        @session.wait_load
      end
    end
  end
end