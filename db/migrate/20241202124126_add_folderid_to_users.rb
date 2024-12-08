class AddFolderidToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_drive_folder_id, :string
  end
end
