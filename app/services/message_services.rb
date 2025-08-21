
class MessageServices
  def self.find_all(app_token, chat_number)
    begin
      chat = Chat.includes(:messages).find_by(application_token: app_token, number: chat_number)
      return ServiceResponse.error("Chat not found") unless chat

      ServiceResponse.success(chat.messages)
    rescue => e
      ServiceResponse.error(e.message)
    end
  end




  def self.create(app_token, chat_number, text)
    chat = Chat.find_by(application_token: app_token, number: chat_number)
    return ServiceResponse.error("Chat not found") unless chat
       number = $redis.incr("#{app_token}:#{chat_number}")
unless number.is_a?(Integer) && number > 0
    return ServiceResponse.error("Invalid msg number generated")
end
begin
  CreateMessageJob.perform_later(number,  text, chat.id)
rescue => e
  return ServiceResponse.error("Failed to enqueue msg creation: #{e.message}")
end
ServiceResponse.success(number)
  rescue => e
    ServiceResponse.error(e.message)
  end



  def self.find(app_token, chat_number, msg_number)
    msg = Message.joins(chat: :application).find_by(
      chats: { number: chat_number },
      applications: { token: app_token },
      number: msg_number
    )

    msg ? ServiceResponse.success(msg) : ServiceResponse.error("Message not found")
  rescue => e
    ServiceResponse.error(e.message)
  end




def self.searchMessages(app_token, chat_number, text)
  begin
    chat = Chat.joins(:application).find_by(applications: { token: app_token }, number: chat_number)
    return ServiceResponse.error("Chat not found") unless chat

    return ServiceResponse.error("Search text cannot be empty") if text.blank?

    results = Message.__elasticsearch__.search({
      query: {
        bool: {
          must: [
            { match: { application_token: app_token } },
            { match: { chat_number: chat_number } },
            {
              wildcard: {
                text: "*#{text.downcase}*"
              }
            }
          ]
        }
      }
    }, index: "chat_messages").records.to_a

    results ? ServiceResponse.success(results) : ServiceResponse.error("no messages")
  rescue => e
    ServiceResponse.error(e.message)
  end
end
end
