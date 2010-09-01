# == Schema Information
# Schema version: 60
#
# Table name: albums
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  privacy         :integer
#  type            :string(255)
#  style           :integer         default(0)
#  open            :boolean
#  event_date      :datetime
#  location        :string(255)
#  stream_share_id :integer
#  reminders       :boolean
#  name            :string(255)
#  suspended       :boolean
#  created_at      :datetime
#  updated_at      :datetime
#

#
#   Copyright 2010, ZangZing LLC;  All rights reserved.  http://www.zangzing.com
#

class Album < ActiveRecord::Base
  usesguid
  attr_accessible :name, :privacy
  
  belongs_to :user
  has_many :photos,           :dependent => :destroy
  has_many :shares,           :dependent => :destroy
  has_many :album_activities, :dependent => :destroy

  validates_presence_of  :user_id
  validates_presence_of  :name
  validates_length_of    :name, :maximum => 50

  default_scope :order => 'created_at DESC'

  PRIVACIES = {'Public' =>'public','Hidden' => 'hidden'};

  def wizard_steps
    [:choose_album_type,:add_photos, :name_album, :edit_album, :contributors, :share]  
  end

  # All url, path and form helpers treat all subclasses as Album
  def self.model_name
    name = "album"
    name.instance_eval do
      def plural;   pluralize;   end
      def singular; singularize; end
      def human;    singularize; end # only for Rails 3
    end
    return name
  end

  def upload_by_user_complete( user )
    shares = Share.find_all_by_user_id_and_sent_at( user.id, nil);
    shares.each { |s| s.deliver() } if shares
    Notifier.deliver_album_upload_complete(user, self).deliver
  end

end
