class AddLatAndLongToCities < ActiveRecord::Migration
  def self.up
    if(!column_exists?(:cities, :lat))
      add_column :cities, :lat, :decimal
    end
    if(!column_exists?(:cities, :lon))
      add_column :cities, :lon, :decimal
    end
  end

  def self.down
    remove_column :cities, :lon
    remove_column :cities, :lat
  end
end
