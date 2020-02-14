class AddColumnsToFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :files, :content_type, :string
    add_column :files, :content_guid, :string
    add_column :files, :download_status, :boolean
    # add_column :files, :created_at, :timestamp
    # add_column :files, :updated_at, :timestamp

  end
end
