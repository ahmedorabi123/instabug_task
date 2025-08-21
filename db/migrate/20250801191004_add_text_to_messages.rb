class AddTextToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :text, :string
  end
end
