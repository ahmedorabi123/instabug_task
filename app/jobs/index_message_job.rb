class IndexMessageJob < ApplicationJob
  queue_as :low

  def perform(message_id)
    message = Message.includes(:chat).find(message_id)

    message.__elasticsearch__.index_document(index: "chat_messages")

  rescue => e
    Rails.logger.error("IndexMessageJob failed: #{e.message}")
  end
end
