module MailgunRails
  module ActionMailer
    def deliver_serialized_mail serialized_mail
      klass = delivery_methods[delivery_method]
      instance = klass.new(send(:"#{delivery_method}_settings"))
      instance.deliver_serialized_mail(serialized_mail)
    end
  end
end

ActionMailer::Base.extend MailgunRails::ActionMailer
