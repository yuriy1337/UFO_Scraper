class RenameColumnShapeToShapeCategoryId < ActiveRecord::Migration
  def self.up
     rename_column :sightings, :shape, :shape_categories_id
  end

  def self.down
    rename_column :sightings, :shape_categories_id, :shape
  end
end
