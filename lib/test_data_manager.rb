# This class tracks the version of the test data set
# You can use this to create a mysql dump file of your development
# db, or work against the test data source directly.  If you
# make changes to the test data and export a dump file, you
# should update the version here and create the dump from here
# this will put a version in the test_data_set_version table
# that can be used when running the rspec tests to determine
# if the dump file should be imported before the tests are run.
#
#
# To create the seed data, change the VERSION below and
# then run the rails console.  From the console type:
#
# TestDataManager.create_seed_data
#
# or you can use the following to run without the console from the command line
#
# if you want to export the current TEST database as seed data do this
# bundle exec rails runner -e test TestDataManager.create_seed_data
#
# if you want to export the current DEVELOPMENT database as seed data do this
# bundle exec rails runner -e development TestDataManager.create_seed_data
#
# The above will create a mysql dump file for the cache and database
# which will be imported with the rpsec tests are run if the current
# test data is out of date via the VERSION.
#
class TestDataManager
  # the version tells us if we have an up to date
  # test data set.  This version is applied just
  # prior to generating the dump file used by the
  # rspec tests.
  # The format should be: INITIALS-DATE-REV
  VERSION = "GWS-2012-03-06-01"

  # do not change
  KEY_NAME = :test_data_ver

  def self.path_to_db_init
    our_dir = File.dirname(__FILE__)
    File.expand_path('../spec/support/db_init', our_dir)
  end

  # writes the current version and exports
  # into the spec/support/db_init directory
  # the seed databases based on your current database
  # state
  def self.create_seed_data
    cur_version = SystemSetting.find_by_name(KEY_NAME) rescue nil
    if cur_version.nil?
      SystemSetting.create( :name  => KEY_NAME,
                            :label => 'Test Data Set Version',
                            :description => 'Test Data Set Version',
                            :data_type  => 'string',
                            :value => VERSION)
    else
      SystemSetting[KEY_NAME] = VERSION
    end
    # make the seed files
    `cd #{path_to_db_init} && ./make_seed_from_#{Rails.env}`
  end

  # load the seed data if we are out of date with
  # respect to the version here
  def self.load_seed_data
    cur_version = SystemSetting[KEY_NAME] rescue ''
    if cur_version != VERSION
      msg = "*** Your test database is out of date.  Loading seed data into test database."
      Rails.logger.info msg
      puts msg
      # out of date, pull the full set in via mysql script
      `cd #{path_to_db_init} && ./load_test_db`

      # now reset the column info since the database changed
      ActiveRecord::Base.reset_column_information
      ActiveRecord::Base.send(:subclasses).each{|klass| klass.reset_column_information rescue nil}

      # now verify the version matches what was expected
      new_version = SystemSetting[KEY_NAME] rescue ''
      if new_version != VERSION
        raise "The imported data version does not match what was expected.  We expected #{VERSION} and got #{new_version} - please make sure you have a valid set of .seed files in your #{path_to_db_init} directory."
      end
    end
  end

end
