class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.text :name
      t.integer :states_id
      t.decimal :total_area
      t.decimal :water_area
      t.decimal :land_area
      t.integer :population
      t.decimal :population_density
      t.integer :lat_deg
      t.integer :lat_min
      t.integer :lat_sec
      t.text :lat_dir
      t.integer :lon_deg
      t.integer :lon_min
      t.integer :lon_sec
      t.text :lon_dir
      t.integer :elevation

      t.timestamps
    end
  end

  def self.down
    drop_table :cities
  end
end
