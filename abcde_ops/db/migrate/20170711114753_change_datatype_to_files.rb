class ChangeDatatypeToFiles < ActiveRecord::Migration[5.0]
  def change
    # change_column :files , :url , :text
    change_column :files , :filename , :string
    change_column :files , :relativefilepath , :text
  end
end
