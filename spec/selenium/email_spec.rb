require './spec/selenium/ui_model'
require './spec/selenium/uimodel_helper'
require './spec/selenium/connector_shared'
require './spec/selenium/gmail_tool'
require 'pony'

MAIL_TEST_DOMAIN = 'test.zangzing.com'

SMTP_OPTIONS = {
        :address        => 'smtp.gmail.com',
        :port           => 587,
        :user_name      => 'zangzingtest@gmail.com',
        :password       => 'share1001photos',
        :authentication => :plain,
        :domain         => "gmail.com" # the HELO domain provided by the client to the server
      }

IMAP_OPTIONS = {
    :host => 'imap.gmail.com',
    :port => 993,
    :ssl => true,
    :login => 'zangzingtest@gmail.com',
    :password => 'share1001photos'
}

describe "Email test" do
  include UimodelHelper
  include ConnectorShared
  
  before(:all) { begin_session!; @@mail_expectations = [] }
  after(:all) { end_session! }

  it "joins as new user" do
    join_as_new_user
    @@mail_expectations << {
      :to => current_user[:email],
      :from => 'postmaster@zangzing.com',
      :subject => 'Welcome to ZangZing',
      :body => "Username: #{current_user[:username]}"
    }
  end

  it "create a new group album" do
    create_new_album #(:group)
  end

  it "gives a name to the album" do
    @@album_name = "eMailed #{current_user[:stamp]}"
    set_album_name @@album_name
    @@album_email = ui.wizard.album_name_tab.get_album_email
  end

  it "adds 3 contributors" do
    @@contributors = [
      "contrib-#{current_user[:stamp].downcase}-a@#{MAIL_TEST_DOMAIN}",
      "contrib-#{current_user[:stamp].downcase}-b@#{MAIL_TEST_DOMAIN}",
      "contrib-#{current_user[:stamp].downcase}-c@#{MAIL_TEST_DOMAIN}"
    ]
    ui.wizard.click_contributors_tab
    #ui.wizard.album_contributors_tab.visible?.should be_true
    ui.wizard.album_contributors_tab.add_contributors @@contributors
    @@contributors.each do |contributor|
       @@mail_expectations << {
        :to => contributor,
        :from => 'postmaster@zangzing.com',
        :subject => 'Somebody shared photos',
        :body => ['has shared a ZangZing album with you', @@album_name]
       }
    end
  end

  it "mails 2 photos from each contributor" do
    photos = Dir[File.join(File.dirname(__FILE__), 'photos_emailable', '*.jpg')]
    @@contributors.each do |contributor_email|
      attaches = {}
      2.times do
        photo = photos[rand(photos.size)-1]
        attaches[File.basename(photo)] = File.open(photo, "rb") { |f| f.read }
      end
      Pony.mail(:from => contributor_email, :to => @@album_email, :attachments => attaches, :subject => 'photos to push',
        :body => 'some photos attached', :via => :smtp, :via_options => SMTP_OPTIONS)
      puts "Photos sent from #{contributor_email}."
      sleep 5
    end
  end

  it "shares album by email with 2 peeps" do
    @@coauthors = [
      "coauth-#{current_user[:stamp].downcase}-first@#{MAIL_TEST_DOMAIN}",
      "coauth-#{current_user[:stamp].downcase}-second@#{MAIL_TEST_DOMAIN}",
    ]
    ui.wizard.click_share_tab
    ui.wizard.album_share_tab.click_share_by_email
    puts "click_share_by_email"
    ui.wizard.album_share_tab.type_emails(@@coauthors)
    @@coauthors.each do |coauth|
       @@mail_expectations << {
        :to => coauth,
        :from => 'postmaster@zangzing.com',
        :subject => 'invited to contribute photos',
        :body => ['invites you to contribute photos', @@album_name]
       }
    end
  end

  it "closes wizard" do
    close_wizard
  end

  it "waits for emailed photos" do
    sleep 160
  end

  it "checks if newly created album contains 6 photos" do
    photos = get_photos_from_added_album(@@album_name)
    photos.count.should == 6
  end

  it "checks if recipients recieved their invitations" do
    GmailTool.config = IMAP_OPTIONS
    3.times do |check_round|
      puts "Checking inbox, #{check_round+1} round..."
      GmailTool.check_inbox do |mail, delete_it|
        @@mail_expectations.each do |expectation|
          next if expectation[:got_it]
          expectation[:got_it] = delete_it = [:from, :to, :subject].all?{ |field| mail.send(field).include?(expectation[field]) } &&
            [expectation[:body]].flatten.all?{ |body_part| mail.body.include?(body_part) }
        end
      end
      break if @@mail_expectations.all?{|e| e[:got_it]}
      sleep 60
    end
    @@mail_expectations.each do |expectation|
      expectation[:got_it].should be_true
    end
  end

end
