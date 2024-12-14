class CreateLogfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :logfiles do |t|
      t.string :file_id
      t.string :title
      t.date :date
      t.string :tag

      t.timestamps
    end
  end
end
