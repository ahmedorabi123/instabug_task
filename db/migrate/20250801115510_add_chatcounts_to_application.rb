class AddChatcountsToApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :applications, :chats_count, :integer
  end
end
