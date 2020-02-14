class ChangeColumnToFiles < ActiveRecord::Migration[5.0]
  def change
    change_column :files , :download_status , :string
  end
end
