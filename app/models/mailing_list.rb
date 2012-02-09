class MailingList < ActiveRecord::Base
  attr_accessible :mailchimp_list_id, :category, :name
  ALL_USERS = "All Users"
  #mailchimp_list_id
  #category i.e. Email::MARKETING
  #name

  #see http://apidocs.mailchimp.com/rtfm/exceptions.field.php
  ALREADY_IN_LIST  = 214
  NOT_IN_THIS_LIST = 215
  NOT_IN_LIST      = 232

  def subscribe_user user
    result = gb.list_subscribe( :id => self.mailchimp_list_id,
                       :email_address => user.email,
                       :merge_vars =>{
                           :U_ID  => user.id,
                           :FNAME => user.first_name,
                           :LNAME => user.last_name,
                           :USERNAME => user.username,
                           :JOIN_DATE =>  user.created_at().strftime( '%y-%m-%d-%H-%M-%S' ),
                           :OPTIN_TIME => user.created_at().strftime( '%y-%m-%d-%H-%M-%S' )
                       },
                       :double_optin => 'false'

    )
    if( result['error'] && result['code'].to_i != ALREADY_IN_LIST )

        raise Exception.new( "Cannot Subscribe User: #{result['code']} #{result['error']}")
    end
  end

  def process_unsubscribe_event user
    user.subscriptions.unsubscribe( self.category )
  end
    
  def unsubscribe_user user
    result = gb.list_unsubscribe( :id => self.mailchimp_list_id,
                       :email_address => user.email,
                       :delete_member => 'true',
                       :send_goodbye => 'false',
                       :send_notify => 'false'
    )
    if( result['error'] && result['code'].to_i != NOT_IN_LIST && result['code'].to_i != NOT_IN_THIS_LIST)
        raise Exception.new( "Cannot Unsubscribe User: #{result['code']} #{result['error']}")
    end
  end

  def update_user old_email, user
     result = gb.list_update_member( :id => self.mailchimp_list_id,
                       :email_address => old_email,
                       :merge_vars =>{
                           :FNAME => user.first_name,
                           :LNAME => user.last_name,
                           :USERNAME => user.username,
                           :EMAIL => user.email
                       })
    if( result['error']&& result['code'].to_i != NOT_IN_THIS_LIST && result['code'].to_i != NOT_IN_LIST)
        raise Exception.new( "Cannot Unsubscribe User: #{result['code']} #{result['error']}")
    end
  end

  def mailchimp_name
    mailchimp_list['name']
  end

  def gb
     @gb ||= Gibbon::API.new(MAILCHIMP_API_KEYS[:api_key])
  end

  def mailchimp_list
    if @list.nil?
      result = gb.lists('filters' => {'list_id' => self.mailchimp_list_id})
      if( result['error'])
        raise Exception.new( "Cannot find Mailing List: #{result['code']} #{result['error']}")
      end
      @list = result['data'][0]
    end
    @list
  end

  #[Email::NEWS, Email::MARKETING]
  def self.subscribe_user( categories, user_id)
     user = User.find( user_id )
     lists = MailingList.find_all_by_category( categories )
     lists.each do |list|
       list.subscribe_user( user )
     end
  end

  def self.unsubscribe_user( categories, user_id, ignore_errors = false  )
     user = User.find( user_id )
     lists = MailingList.find_all_by_category( categories )
     lists.each do |list|
       begin
         list.unsubscribe_user( user )
       rescue Exception => ex
         raise ex unless ignore_errors
       end
     end
  end

  def self.subscribe_new_user user_id
    ZZ::Async::MailingListSync.enqueue( 'subscribe_user', [Email::NEWS, Email::MARKETING, Email::ONCE], user_id )
  end

  # immediately send out request to unsubscribe this user since being deleted
  # don't want to wait for resque job because we will be gone by then and this
  # obviously happens only rarely in the system
  def self.user_cleanup(user)
    # make sure that resque worker is not filtered for this call
    if MailingListSync.loopback_on? == false || MailingListSync.should_loopback?
      unsubscribe_user([Email::NEWS, Email::MARKETING, Email::ONCE], user.id, true)
    end
  end

  def self.update_user old_email, user_id
     user = User.find( user_id )
     MailingList.find_each do |list|
       list.update_user( old_email, user )
     end
  end

end