class AddWsIdAndWsDistanceToSightings < ActiveRecord::Migration
  def self.up
    add_column :sightings, :ws_id, :integer
    add_column :sightings, :ws_distance, :decimal
  end

  def self.down
    remove_column :sightings, :ws_distance
    remove_column :sightings, :ws_id
  end
end
