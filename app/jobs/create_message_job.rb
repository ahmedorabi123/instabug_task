class CreateMessageJob < ApplicationJob
  queue_as :critical

  def perform(number, text, chat_id)
    begin
msg = Message.create!(number: number, text: text, chat_id: chat_id)


     $redis.sadd("newCreatedMessages", msg.chat_id)

     IndexMessageJob.perform_later(msg.id)

    rescue => e
    Rails.logger.error("CreateMessageJob failed: #{e.message}")

    end
  end
end
