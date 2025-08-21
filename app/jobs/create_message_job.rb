class CreateMessageJob < ApplicationJob
  queue_as :default

  def perform(number, text, chat_id)
    begin
msg = Message.create!(number: number, text: text, chat_id: chat_id)


 $redis.sadd("newCreatedMessages", msg.chat_id)

     IndexMessageJob.perform_later(msg.id)

    rescue => e
    Rails.logger.error("CreateMessageJob failed: #{e.message}")
      # Optionally notify with error tracking (e.g., Sentry/Rollbar) here
    end
  end
end
