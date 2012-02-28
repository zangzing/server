class RemoveMailchimpFromTemplates < ActiveRecord::Migration
  def self.up
    #remove_column :email_templates, :mc_campaign_id
  end

  def self.down
    #add_column :email_templates, :mc_campaign_id, :string, :default => ""
    #EmailTemplate.reset_column_information
    #campaign_ids = {
    #  'email.photosready' => 'ed39f93a53',
    #  'email.password' => '0dfd8b828a',
    #  'email.albumshared' => 'e427cb2a77',
    #  'email.albumliked' => '54bf6462bd',
    #  'email.photoliked' => '229a03ecff',
    #  'email.userliked' => '1af6506f54',
    #  'email.contributionerror' => '2453d696c7',
    #  'email.albumupdated' => 'cd154a1de5',
    #  'email.contributorinvite' => 'bcbed116ba',
    #  'email.welcome' => '9137f37b86'
    #}
    #campaign_ids.each do |category, campaign_id|
    #  EmailTemplate.where(:category => category).update_all(:mc_campaign_id => campaign_id)
    #end
  end
end
