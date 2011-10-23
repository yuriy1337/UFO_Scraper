class CreateSightings < ActiveRecord::Migration
  def self.up
    create_table :sightings do |t|
      t.datetime :occurance_time
      t.integer :cities_id
      t.string :shape
      t.integer :duration
      t.text :summary
      t.date :post_date

      t.timestamps
    end
  end

  def self.down
    drop_table :sightings
  end
end
