class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.string :country
      t.string :value
      t.string :lat
      t.string :lng

      t.timestamps
    end
  end
end
