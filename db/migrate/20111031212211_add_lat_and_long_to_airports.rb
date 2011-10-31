class AddLatAndLongToAirports < ActiveRecord::Migration
  def self.up
    if(!column_exists?(:airports, :lat))
      add_column :airports, :lat, :decimal
    end
    if(!column_exists?(:airports, :lon))
      add_column :airports, :lon, :decimal
    end
  end

  def self.down
    remove_column :airports, :lon
    remove_column :airports, :lat
  end
end
