module Mail
  class Message
    attr_accessor :mailgun_variables
    attr_accessor :mailgun_options
    attr_accessor :mailgun_recipient_variables
    attr_accessor :mailgun_headers

    def serialize
      delivery_method.serialize(self)
    end
  end
end
