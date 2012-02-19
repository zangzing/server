class SystemController < ApplicationController

  # return the system status and health info
  #
  # This is called as (GET):
  #
  # /zz_api/system/status
  #
  # You must have a super moderator role as determined by the current logged in users rights.
  #
  # Returns the sharing info in the following form:
  #
  #{
  #    :external_services => {
  #        :service_name1 => true/false,   # health entry for each service, bitly,facebook, etc}
  #        :service_name2 => true/false,   # health entry for each service, bitly,facebook, etc}
  #        ...
  #    },
  #    :photos => {
  #        :total => total
  #        :today => today,
  #        :yesterday => yesterday,
  #        :this_week => this week
  #        :last_week => last week,
  #        :this_month => this month,
  #        :last_month => last month
  #    },
  #    :albums => {
  #        :total => total
  #        :today => today,
  #        :yesterday => yesterday,
  #        :this_week => this week
  #        :last_week => last week,
  #        :this_month => this month,
  #        :last_month => last month
  #    },
  #    :users => {
  #        :total => @total_usercount,
  #        :today => @today_usercount,
  #        :yesterday => @yesterday_usercount,
  #        :this_week => @this_week_usercount,
  #        :last_week => @last_week_usercount,
  #        :this_month => @this_month_usercount,
  #        :last_month => @last_month_usercount
  #    },
  #    :invited_users => {
  #        :total => @total_invited_usercount,
  #        :today => @today_invited_usercount,
  #        :yesterday => @yesterday_invited_usercount,
  #        :this_week => @this_week_invited_usercount,
  #        :last_week => @last_week_invited_usercount,
  #        :this_month => @this_month_invited_usercount,
  #        :last_month => @last_month_invited_usercount
  #    },
  #    :health_check =>   {
  #       :app_servers => {
  #         :status => 'Not Checked' : 'OK' : 'FAIL'
  #         :msg => extra string message
  #         :took => time in float seconds that check took
  #         :servers => [app_server,...]  array of app server strings
  #         :rails_env => the rails environment
  #       }
  #       :redis => {
  #         :status => 'Not Checked' : 'OK' : 'FAIL'
  #         :msg => extra string message
  #         :took => time in float seconds that check took
  #         :server => the redis server string
  #       }
  #       :database => {
  #         :status => 'Not Checked' : 'OK' : 'FAIL'
  #         :msg => extra string message
  #         :took => time in float seconds that check took
  #       }
  #       :zza => {
  #         :status => 'Not Checked' : 'OK' : 'FAIL'
  #         :msg => extra string message
  #         :took => time in float seconds that check took
  #       }
  #    }
  #}
  def zz_api_status
    return unless require_user && require_super_moderator

    zz_api do
      SystemStats.new.gather_stats
    end
  end

end