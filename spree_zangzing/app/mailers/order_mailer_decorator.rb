require File.expand_path(File.dirname(__FILE__) + '/../../../lib/zz/mailer')
require File.expand_path(File.dirname(__FILE__) + '/../../../app/helpers/pretty_url_helper')


OrderMailer.class_eval do
  include ZZ::Mailer
  include PrettyUrlHelper

  add_template_helper(PrettyUrlHelper)

end
