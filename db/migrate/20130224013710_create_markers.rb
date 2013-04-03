class CreateMarkers < ActiveRecord::Migration
  def change
    create_table :markers do |t|
      t.string :lat
      t.string :lng
      t.string :value
      t.integer :map_id
      t.integer :markerId

      t.timestamps
    end
  end
end
