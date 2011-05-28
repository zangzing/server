require 'net/imap'
require 'net/http'
require 'net/https'

class GmailTool
  def self.config=(val)
    @@config = val
  end

  def self.config
    @@config
  end

  def self.check_inbox
    begin
      # make a connection to imap account
      imap = Net::IMAP.new(@@config[:host], @@config[:port], @@config[:ssl])
      imap.login(@@config[:login], @@config[:password])
      # select inbox as our mailbox to process
      imap.select('Inbox')
      # get all emails that are in inbox that have not been deleted
      imap.uid_search(["NOT", "DELETED"]).each do |uid|
        # fetches the straight up source of the email for tmail to parse
        raw_email = imap.uid_fetch(uid, ['RFC822']).first.attr['RFC822']
        delete_it = false
        yield Mail.new(raw_email), delete_it
        if delete_it
          # there isn't move in imap so we copy to new mailbox and then delete from inbox
          imap.uid_copy(uid, "[Gmail]/All Mail")
          imap.uid_store(uid, "+FLAGS", [:Deleted])
        end
      end
      # expunge removes the deleted emails
      imap.expunge
      imap.logout
      imap.disconnect
    # NoResponseError and ByResponseError happen often when imap'ing
    #rescue Net::IMAP::NoResponseError => e
      # send to log file, db, or email
    #rescue Net::IMAP::ByeResponseError => e
      # send to log file, db, or email
    #rescue => e
      # send to log file, db, or email
    end
  end


end