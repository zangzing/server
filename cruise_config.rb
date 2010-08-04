# Project-specific configuration for CruiseControl.rb

Project.configure do |project|

  # Send email notifications about broken and fixed builds to email1@your.site, email2@your.site (default: send to nobody)
  project.email_notifier.emails = ["dev@zangzing.com"]

  # Set email 'from' field to john@doe.com:
  # project.email_notifier.from = 'server-cruisecontrol@zangzing.com'

  # Build the project by invoking rake task 'custom'
  # project.rake_task = 'custom'

  # Build the project by invoking shell script "build_my_app.sh". Keep in mind that when the script is invoked,
  # current working directory is <em>[cruise&nbsp;data]</em>/projects/your_project/work, so if you do not keep build_my_app.sh
  # in version control, it should be '../build_my_app.sh' instead
  # project.build_command = 'build_my_app.sh'

  # Ping Subversion for new revisions every 5 minutes (default: 30 seconds)
  # project.scheduler.polling_interval = 5.minutes

  # Force the project always build once every day and always build whether there are source control changes or not
  # project.scheduler.polling_interval = 1.day
  # project.scheduler.always_build = true

  # Force the project to check for source control changes every given time interval, but NOT build if there are no changes
  # project.triggered_by ScheduledBuildTrigger.new(project, :build_interval => 5.minutes, :start_time => 2.minutes.from_now)
end
