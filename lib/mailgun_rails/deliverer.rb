module MailgunRails
  class Deliverer

    attr_accessor :settings

    def initialize(settings)
      self.settings = settings
    end

    def domain
      self.settings[:domain]
    end

    def api_key
      self.settings[:api_key]
    end

    def deliver!(rails_message)
      response = mailgun_client.send_message(domain, build_mailgun_message(rails_message))

      if response.code == 200
        mailgun_message_id = JSON.parse(response.body.to_s)['id']
        rails_message.message_id = mailgun_message_id
      end

      response
    end

    def serialize(rails_message)
      build_mailgun_message(rails_message).message
    end

    private

    def build_mailgun_message(rails_message)
      mb_obj = Mailgun::MessageBuilder.new

      mb_obj.from(rails_message[:from].formatted.first)
      mb_obj.add_recipient('h:reply-to', rails_message[:reply_to].formatted.first) if rails_message[:reply_to]
      mb_obj.add_recipient(:to, rails_message[:to].formatted.first)

      %i(cc bcc).each do |key|
        mb_obj.add_recipient(key, rails_message[key].formatted.first) if rails_message[key]
      end

      mb_obj.subject(rails_message.subject)
      mb_obj.body_text(extract_text(rails_message))
      mb_obj.body_html(extract_html(rails_message))

      rails_message.mailgun_variables.try(:each) do |name, value|
        mb_obj.add_custom_parameter("v:#{name}", value)
      end

      rails_message.mailgun_options.try(:each) do |name, value|
        mb_obj.add_custom_parameter("o:#{name}", value)
      end

      rails_message.mailgun_headers.try(:each) do |name, value|
        mb_obj.add_custom_parameter("h:#{name}", value)
      end

      if rails_message.attachments.any?
        rails_message.attachments.each do |attachment|
          if attachment.inline?
            add_inline_image(attachment)
          else
            mb_obj.add_attachment(attachment)
          end
        end
      end

      mb_obj
    end

    # @see http://stackoverflow.com/questions/4868205/rails-mail-getting-the-body-as-plain-text
    def extract_html(rails_message)
      if rails_message.html_part
        rails_message.html_part.body.decoded
      else
        rails_message.content_type =~ /text\/html/ ? rails_message.body.decoded : nil
      end
    end

    def extract_text(rails_message)
      if rails_message.multipart?
        rails_message.text_part ? rails_message.text_part.body.decoded : nil
      else
        rails_message.content_type =~ /text\/plain/ ? rails_message.body.decoded : nil
      end
    end

    def mailgun_client
      @mailgun_client ||= Mailgun::Client.new(api_key)
    end
  end
end

ActionMailer::Base.add_delivery_method :mailgun, MailgunRails::Deliverer
