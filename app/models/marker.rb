class Marker < ActiveRecord::Base
  attr_accessible :lat, :lng, :map_id, :markerId, :value
  belongs_to :map
  default_scope order('created_at DESC')
end
