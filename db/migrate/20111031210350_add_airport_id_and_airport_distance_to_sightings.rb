class AddAirportIdAndAirportDistanceToSightings < ActiveRecord::Migration
  def self.up
    add_column :sightings, :airport_id, :integer
    add_column :sightings, :airport_distance, :decimal
  end

  def self.down
    remove_column :sightings, :airport_distance
    remove_column :sightings, :airport_id
  end
end
