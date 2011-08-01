require File.dirname(__FILE__) + '/../../../lib/zz/mailer'

OrderMailer.class_eval do
  include ZZ::Mailer
end