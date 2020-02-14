class AddColumnToFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :files , :content_id, :integer
  end
end
