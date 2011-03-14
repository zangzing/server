require 'zz/mailchimp/error'
require 'zz/mailchimp/message'
require 'zz/mailchimp/notifier'

module ZZ
  module MailChimp
    
    Chimp= Hominid::API.new(MAILCHIMP_API_KEYS[:api_key])
    #names of lists/campaigns that should exist
    #each transactional campaign has an associated list both with the same name

    $campaigns= nil

    # This method is to be called at startup to verify that mailchimp is up and to cache all trans campaigns
    # trans campaigns are stored in a hash by name for easy retrieval
    def self.load_setup()
        #check that mailchimp is up
#        ping
        #Make sure all lists and campaigns exist in MailChimp and cache their IDs
        tmp_camps = get_transactional_campaigns
        raise Error, "MailChimp Setup Error: No Transactional campaigns found (type 'trans')"  if tmp_camps.nil? || tmp_camps.length <= 0
        $campaigns = Hash.new()
        tmp_camps.each do | camp |
          $campaigns[camp['title']]=camp
        end
    end

    def self.ping
      Chimp.ping()
    end

    def self.get_templates
       result = Chimp.templates({:user => true, :gallery => false, :base => false})
       if result.nil? || result['user'].length <= 0
         return []
       else
         return result['user']
       end
    end

    def self.get_lists
       result = Chimp.lists({})
       if result.nil? || result['total'].to_i <= 0
         return []
       else
         return result['data']
       end
    end

    def self.get_transactional_campaigns
      Chimp.find_campaigns_by_type( 'trans' )
    end

    def self.get_regular_campaigns
          Chimp.find_campaigns_by_type( 'regular' )
    end


    def self.create_transactional_campaign( title, list_id, template_id, subject, from_email, from_name )
      begin
            Chimp.campaign_create( 'trans',
                                   { :list_id => list_id,
                                     :template_id => template_id,
                                     :subject => subject,
                                     :from_email => from_email,
                                     :from_name  => from_name,
                                     :title => title
                                   },
                                   { :text => 'Text option'
                                   },{},{})
      rescue Hominid::APIError => e
          raise Error, "Campaign Creation Error: "+e.message
      end
    end

    def self.delete_campaign( id )
      begin
            Chimp.campaign_delete( id )
      rescue Hominid::APIError => e
          raise Error, "Campaign Delete Error: "+e.message
      end
    end
    
  end
end


=begin
 def main

 ZZ::MailChimp.load_setup

 ZZ::MailChimp.get_lists.each{ |p| p p}

 result  = MailChimpNotifier.email_integration_testing( 'mauricio@nextstagellc.com',
                                               { :FNAME => "Mauricio",  #merge_vars
                                                 :LNAME => "Alvarez",
                                                 :MSG   => "I Hope you receive this message in health"
                                               }).deliver
  if result
        puts "Message Sent (subscribe, unsubscribe, send)"
  else
        puts "Message NOT Sent (subscribe, unsubscribe, send)"
  end

end

class MailChimpNotifier

  def self.email_integration_testing( to_email, merge_vars )
     ZZ::MailChimp::Message.new( 'email-integration-testing', to_email, merge_vars )
  end

end






  templates = h.templates({:user => true, :gallery => false, :base => false})
  t = templates['user'].find {|t| t["name"] == TEMPLATE_NAME}
  puts 'Template '+t["name"]+' Found with ID ==>'+t['id'].to_s+'<=='

  # used to obtain template sections which can be replaced with html (oriented towards campaign editing)
  # ti = h.template_info(t['id'].to_i, 'user')
  # p ti['sections']

  folders = h.folders()
  f = folders.find {|f| f["name"] == FOLDER_NAME}
  puts 'Folder '+f["name"]+' Found with ID ==>'+f['folder_id'].to_s+'<=='

  if false
     c =  h.campaign_create( 'trans',
                          { :list_id => l['id'],
                            :template_id => t['id'],
                            :subject => 'MC Integration Testing',
                            :from_email => 'mauricio@zangzing.com',
                            :from_name  => 'ZangZing Mailchimp Transactional Emailer',
                            #:to_name =>'Dear MC Integration Testing User',
                            :title => CAMPAIGN_NAME
                          },
                          {
                            :text => 'Text option'
                          },
                          {},{})
    puts 'Trans Campaign '+CAMPAIGN_NAME+' Created with ID ==>'+c.to_s+'<=='
  end
  c = h.find_campaigns_by_list_name( LIST_NAME )[0]
  puts 'Campaign '+c['title']+' Found with ID ==>'+c['id'].to_s+'<=='


=end

