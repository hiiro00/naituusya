class AddIndexToTheme < ActiveRecord::Migration[5.2]
  def change
    add_index :themes, :content, :unique => true
  end
end
