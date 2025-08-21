class AddIndexToEntities < ActiveRecord::Migration[8.0]
  def change
    add_index :applications, :token, unique: true
   add_index :chats, [ :application_token, :number ], unique: true
    add_index :messages, [ :chat_id, :number ], unique: true
  end
end
