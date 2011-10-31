class CreateWeatherStations < ActiveRecord::Migration
  def self.up
    create_table :weather_stations do |t|
      t.string :nws
      t.integer :states_id
      t.integer :cities_id
      t.text :name
      t.integer :lat_deg
      t.integer :lat_min
      t.integer :lat_sec
      t.string :lat_dir
      t.integer :lon_deg
      t.integer :lon_min
      t.integer :lon_sec
      t.string :lon_dir
      t.integer :elevation

      t.timestamps
    end
  end

  def self.down
    drop_table :weather_stations
  end
end
