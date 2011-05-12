class AddHomepageDeploySetting < ActiveRecord::Migration
  def self.up
    SystemSetting.create( :name  => :homepage_deploy_tag,
                          :label => 'Deploy Tag for V3 Homepage',
                          :description => 'Current deploy tag for v3homepage repository',
                          :data_type  => 'string',
                          :value => 'origin/master')
  end

  def self.down
  end
end
