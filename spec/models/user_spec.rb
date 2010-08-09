# == Schema Information
# Schema version: 20100804213110
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  name                :string(255)
#  email               :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  remember_token      :string(255)
#  admin               :boolean
#  style               :string(255)     default("white")
#  crypted_password    :string(255)
#  password_salt       :string(255)
#  persistence_token   :string(255)
#  single_access_token :string(255)
#  perishable_token    :string(255)     default(""), not null
#  login_count         :integer
#  failed_login_count  :integer
#  last_request_at     :date
#  current_login_at    :date
#  last_login_at       :date
#  current_login_ip    :string(255)
#  last_login_ip       :string(255)
#

require 'spec_helper'

describe User do
  before(:each) do
    @attr = { :name => "Example User",
              :email => "example@user.com",
              :password => "1password",
              :password_confirmation =>"1password",
              :style => "white"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end


  it "should reject names that exceed the max size" 

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end


  describe "password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
              should_not be_valid
    end
    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
              should_not be_valid
    end
    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end
    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
    it "should reject passwords that do not meet minimum complexity requirements"
  end

  describe "user preferences" do
    before(:each) do
      @user = User.create(@attr)
    end

    it "should have style attribute accessors" do
      @user.should respond_to(:style)
    end
  end


  describe "album associations" do
    before(:each) do
      @user = User.create!(@attr)
      @album1 = Factory(:album, :user => @user, :created_at => 1.day.ago)
      @album2 = Factory(:album, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have an albums attribute" do
      @user.should respond_to(:albums)
    end

    it "should have the right albums in the right order" do
      @user.albums.should == [@album2, @album1]
    end
    
    it "should destroy associated albums" do
         pending ("Stubbed temporarily. Must Fix")
          @user.destroy
          [@album1, @album2].each do |album|
            Album.find_by_id(album.id).should be_nil
          end
    end
    
    describe "homepage grid view" do
          it "should have a grid view" do
            pending "Not there yet but coming soon..."
            @user.should respond_to(:feed)
          end

          it "should include the user's albums" do
            pending "Not there yet but coming soon..."            
            @user.feed.include?(@album1).should be_true
            @user.feed.include?(@album2).should be_true
          end
          it "should include followees albums" do
            pending "Not there yet but coming soon..."            
            album = Factory(:album,
                          :user => Factory(:user, :email => Factory.next(:email)))
            @user.feed.include?(album).should be_false
          end
    end
  end
end
