class CreateVillages < ActiveRecord::Migration[5.2]
  def change
    create_table :villages do |t|
      t.integer :roomNum
      t.integer :villageNum
      t.text :name
      t.text :position
      t.text :theme
      t.text :comment1
      t.text :comment2

      t.timestamps
    end
  end
end
