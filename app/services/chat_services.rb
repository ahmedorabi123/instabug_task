require "redis"


class ChatServices
  def self.find_all(app_token)
    app = Application.includes(chats: :messages).find_by(token: app_token)
    return ServiceResponse.error("Application not found") unless app

    ServiceResponse.success(app.chats)
  rescue => e
    ServiceResponse.error(e.message)
  end



  def self.create(app_token)
    app = Application.find_by(token: app_token)
    return ServiceResponse.error("Application not found") unless app

    number = $redis.incr(app_token)
    unless number.is_a?(Integer) && number > 0
      return ServiceResponse.error("Invalid chat number generated")
    end
begin
  CreateChatJob.perform_later(app_token, number, app.id)
rescue => e
  return ServiceResponse.error("Failed to enqueue chat creation: #{e.message}")
end
ServiceResponse.success(number)
  rescue => e
    ServiceResponse.error(e.message)
  end




def self.find(app_token, chat_number)
  chat = Chat.includes(:messages).find_by(application_token: app_token, number: chat_number)
  chat ? ServiceResponse.success(chat) : ServiceResponse.error("Chat not found")
rescue => e
  ServiceResponse.error(e.message)
end
end
