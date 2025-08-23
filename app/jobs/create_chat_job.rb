class CreateChatJob < ApplicationJob
  queue_as :critical

  def perform(application_token, chat_num,  application_id)
    begin
      chat = Chat.create!(number: chat_num, application_token: application_token, application_id: application_id)

      $redis.sadd("newCreatedChats", chat.application_id)
    rescue => e
      Rails.logger.error("CreateChatJob failed: #{e.message}")
    end
  end
end
