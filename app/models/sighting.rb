class Sighting < ActiveRecord::Base
  belongs_to :city, :class_name => "City", :foreign_key => 'cities_id'
end
