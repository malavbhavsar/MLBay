class CreateAlgorithms < ActiveRecord::Migration
  def change
    create_table :algorithms do |t|
      t.string :name
      t.string :algorithm
      t.binary :data, :limit => 10.megabytes

      t.timestamps
    end
  end
end
