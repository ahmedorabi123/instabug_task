class UpdateMessageCountsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    chat_ids = $redis.smembers("newCreatedMessages").map(&:to_i)
    return if chat_ids.empty?

    # Group messages by chat_id and count them
    msg_count = Message.where(chat_id: chat_ids).group(:chat_id).count

    msg_count.each do |chat_id, msg_number|
      chat = Chat.find_by(id: chat_id)
      next unless chat

      acc_msgs = msg_number
      chat.update(messages_count: acc_msgs)
    end

    # Clear processed IDs from Redis
    $redis.del("newCreatedMessages")
  rescue => e
    Rails.logger.error("UpdateMessageCountsJob failed: #{e.message}")
    # Optionally: notify error tracking system like Sentry
  end
end
