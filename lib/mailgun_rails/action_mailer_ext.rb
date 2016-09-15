module MailgunRails
  module ActionMailer
    def deliver_serialized_mail serialized_message
      instance = MailgunRails::Deliverer.new(mailgun_settings)
      instance.deliver_serialized_mail(serialized_message)
    end
  end
end

ActionMailer::Base.extend MailgunRails::ActionMailer
