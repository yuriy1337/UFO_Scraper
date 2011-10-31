# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111031212211) do

  create_table "airports", :force => true do |t|
    t.decimal  "lon"
    t.decimal  "lat"
    t.string   "icao"
    t.string   "iata"
    t.text     "name"
    t.integer  "cities_id"
    t.integer  "lat_deg"
    t.integer  "lat_min"
    t.integer  "lat_sec"
    t.string   "lat_dir"
    t.integer  "lon_deg"
    t.integer  "lon_min"
    t.integer  "lon_sec"
    t.string   "lon_dir"
    t.integer  "altitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.decimal  "lon"
    t.decimal  "lat"
    t.text     "name"
    t.integer  "states_id"
    t.decimal  "total_area"
    t.decimal  "water_area"
    t.decimal  "land_area"
    t.integer  "population"
    t.decimal  "population_density"
    t.integer  "lat_deg"
    t.integer  "lat_min"
    t.integer  "lat_sec"
    t.text     "lat_dir"
    t.integer  "lon_deg"
    t.integer  "lon_min"
    t.integer  "lon_sec"
    t.text     "lon_dir"
    t.integer  "elevation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scrapers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shape_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sightings", :force => true do |t|
    t.datetime "occurance_time"
    t.integer  "cities_id"
    t.string   "shape_categories_id"
    t.integer  "duration"
    t.text     "summary"
    t.date     "post_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "airport_id"
    t.decimal  "airport_distance"
  end

  create_table "states", :force => true do |t|
    t.text     "name"
    t.text     "abbr"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_of_sightings"
  end

  create_table "weather_stations", :force => true do |t|
    t.decimal  "lon"
    t.decimal  "lat"
    t.string   "nws"
    t.integer  "states_id"
    t.integer  "cities_id"
    t.text     "name"
    t.integer  "lat_deg"
    t.integer  "lat_min"
    t.integer  "lat_sec"
    t.string   "lat_dir"
    t.integer  "lon_deg"
    t.integer  "lon_min"
    t.integer  "lon_sec"
    t.string   "lon_dir"
    t.integer  "elevation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
