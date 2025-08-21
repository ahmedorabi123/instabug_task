class AddMessagesCountToChat < ActiveRecord::Migration[8.0]
  def change
    add_column :chats, :messages_count, :integer
  end
end
