class SubscriptionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :mcsync

  def unsubscribe
   @subs = Subscriptions.find_by_unsubscribe_token!( params[:id] )
   render :layout =>false
  end

  def update
     @subs = Subscriptions.find( params[:id])
     @subs.update_attributes( params[:subscriptions] )
     flash[:notice] = 'Your email preferences have been saved!'
     case params[:next]
      when 'join'
        redirect_to :controller =>:users, :action => :join, :email=>@subs.email, :email2=>@subs.email
      when 'signin'
        redirect_to :controller =>:user_sessions, :action => :new, :email=>@subs.email, :email2=>@subs.email
       else
        redirect_to :back
     end
  end

  # This call is designed to receive a mailchimp webhook to keep the Mailing Lists in sync
  # more info here http://apidocs.mailchimp.com/webhooks/
  # the call has to remain open to the world but for minimal security the call
  # uses a known secret passed as part of the url with name :token
  # urls look like www.zangzing.com/mcsync?token=9543BHEA87654
  # if the secret matches then the call is coming from MailChimp
  def mcsync
    if params['token'] && params['token'] == 'FG58TRDXxs298Via9543BiddfzzHEAx8T7654'
      if params['type'] && ( params['type'] == 'unsubscribe' || params['type'] == 'cleaned' )
        if params['data'] && params['data']['email'] && params['data']['list_id']
          list_id = params['data']['list_id']
          list = MailingList.find_by_mailchimp_list_id(list_id)
          email = params['data']['email']
          user = User.find_by_email( email )
          user.subscriptions.unsubscribe( list.category )
        end
      end
    end
    render :nothing => true, :status => 200
  end
end