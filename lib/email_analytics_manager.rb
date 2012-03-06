

class EmailAnalyticsManager

  # log the fact that we send share/invite/etc message
  # to these email addresses. used in rollup
  def self.log_share_message_sent(sent_by_user, message_type, emails, errors)
    begin
      unique_emails = emails.uniq
      unique_non_reg_email_count = 0

      unique_emails.uniq.each do |email|
        if !User.find_by_email(email)
          unique_non_reg_email_count += 1
        end
      end

      xdata = {
        :message_type => message_type,
        :total_emails => addresses.length,
        :unique_emails => unique_emails.length,
        :unique_non_reg_emails => unique_non_reg_email_count,
        :errors  => errors.length
      }


      ZZ::ZZA.new.track_event('share.email.stats', xdata, 1, sent_by_user.id)

    rescue Exception => ex
      Rails.logger.error small_back_trace(ex)
    end
  end
end