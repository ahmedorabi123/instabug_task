class UpdateMessageCountsJob < ApplicationJob
  queue_as :medium

  def perform(*args)
    chat_ids = $redis.smembers("newCreatedMessages").map(&:to_i)
    return if chat_ids.empty?

    # Process in batches of 500 IDs at a time
    chat_ids.each_slice(500) do |batch_ids|
      msg_count = Message.where(chat_id: batch_ids).group(:chat_id).count

      msg_count.each do |chat_id, msg_number|
        chat = Chat.find_by(id: chat_id)
        next unless chat

        chat.update(messages_count: msg_number)
      end
    end

    $redis.del("newCreatedMessages")

  rescue => e
    Rails.logger.error("UpdateMessageCountsJob failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
  end
end
