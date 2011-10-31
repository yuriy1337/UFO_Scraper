class CreateShapeCategories < ActiveRecord::Migration
  def self.up
    create_table :shape_categories do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :shape_categories
  end
end
