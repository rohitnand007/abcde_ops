class CreateFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :files,id: false do |t|
      t.string :url, primary_key: true
      t.string :filename
      t.string :relativefilepath
      t.string :file_md5
      t.string :url_md5
      t.string :is_sync
      t.datetime :date_created
      # t.string :content_type
      # t.string :content_guid
      # t.boolean :download_status
      t.timestamps
    end
  end
end
