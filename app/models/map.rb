class Map < ActiveRecord::Base
  attr_accessible :country, :lat, :lng, :value
  has_many :markers, :dependent => :destroy
  default_scope order('created_at DESC')
end
