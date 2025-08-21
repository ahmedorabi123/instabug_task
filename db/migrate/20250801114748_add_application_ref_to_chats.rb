class AddApplicationRefToChats < ActiveRecord::Migration[8.0]
  def change
    add_reference :chats, :application, null: false, foreign_key: true
  end
end
