require File.expand_path(File.dirname(__FILE__) + '/../../../lib/zz/mailer')

OrderMailer.class_eval do
  include ZZ::Mailer
end