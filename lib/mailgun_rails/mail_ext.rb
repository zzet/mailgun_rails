module Mail
  class Message
    attr_accessor :mailgun_variables
    attr_accessor :mailgun_options
    attr_accessor :mailgun_recipient_variables
    attr_accessor :mailgun_headers

    def serialize
      if delivery_method.respond_to?(:serialize)
        delivery_method.serialize(self)
      else
        instance = MailgunRails::Deliverer.new(ActionMailer::Base.mailgun_settings)
        instance.serialize(self)
      end
    end
  end
end
