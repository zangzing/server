class AddFacebookSystemSettingsPart2 < ActiveRecord::Migration
  def self.up
    SystemSetting.create( :name  => :facebook_post_caption,
                          :label => 'Caption',
                          :description => 'Text displayed under the asset name by user line (Not Clickable)',
                          :data_type  => 'string',
                          :value => 'www.zangzing.com')
    SystemSetting.create( :name  => :facebook_post_description,
                          :label => 'Description',
                          :description => 'Boilerplate text displayed in gray next to photo under caption',
                          :data_type  => 'string',
                          :value => 'ZangZing is a new group photo sharing service. Click Join ZangZing to get on the early access list.  It\'s free.')
    SystemSetting.create( :name  => :facebook_post_actions,
                          :label => 'Actions',
                          :description => 'A JSON hash of name:link pairs for actions displayed at the bottom next to like and comment',
                          :data_type  => 'string',
                          :value => "{\"name\":\"Join ZangZing\",\"link\":\"http://www.zangzing.com/join\"}")
  end

  def self.down
  end
end
