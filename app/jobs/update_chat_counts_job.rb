class UpdateChatCountsJob < ApplicationJob
  queue_as :medium

  def perform
    Rails.logger.info("Starting UpdateChatCountsJob...")

    begin
      app_ids = $redis.smembers("newCreatedChats").map(&:to_i)
      return if app_ids.empty?

      chats_by_app = Chat.where(application_id: app_ids).group(:application_id).count

      chats_by_app.each do |app_id, new_chat_count|
        app = Application.find_by(id: app_id)
        next unless app

        app.update(chats_count: new_chat_count)
      end

      $redis.del("newCreatedChats")
      Rails.logger.info("UpdateChatCountsJob completed successfully.")

    rescue => e
      Rails.logger.error("UpdateChatCountsJob failed: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))

      # Optional: Report to an error tracker like Sentry/Rollbar here
      # Sentry.capture_exception(e)
    end
  end
end
