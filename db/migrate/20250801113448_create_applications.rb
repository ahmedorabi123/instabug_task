class CreateApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :applications do |t|
      t.string :name
      t.string :token

      t.timestamps
    end
  end
end
