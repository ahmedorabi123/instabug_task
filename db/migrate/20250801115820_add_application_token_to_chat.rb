class AddApplicationTokenToChat < ActiveRecord::Migration[8.0]
  def change
    add_column :chats, :application_token, :string
  end
end
