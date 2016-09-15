require 'action_mailer'
require 'json'
require 'mailgun'

Dir[File.dirname(__FILE__) + '/mailgun_rails/*.rb'].each {|file| require file }

module MailgunRails
end
