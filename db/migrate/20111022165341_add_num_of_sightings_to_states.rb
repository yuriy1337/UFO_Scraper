class AddNumOfSightingsToStates < ActiveRecord::Migration
  def self.up
    add_column :states, :num_of_sightings, :integer
  end

  def self.down
    remove_column :states, :num_of_sightings
  end
end
