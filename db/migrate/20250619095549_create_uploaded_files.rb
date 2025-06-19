class CreateUploadedFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :uploaded_files do |t|
      t.string :filename
      t.integer :size
      t.string :content_type
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
