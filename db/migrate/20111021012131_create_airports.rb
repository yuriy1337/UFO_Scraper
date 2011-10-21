class CreateAirports < ActiveRecord::Migration
  def self.up
    create_table :airports do |t|
      t.string :icao
      t.string :iata
      t.text :name
      t.integer :cities_id
      t.integer :lat_deg
      t.integer :lat_min
      t.integer :lat_sec
      t.string :lat_dir
      t.integer :lon_deg
      t.integer :lon_min
      t.integer :lon_sec
      t.string :lon_dir
      t.integer :altitude

      t.timestamps
    end
  end

  def self.down
    drop_table :airports
  end
end
