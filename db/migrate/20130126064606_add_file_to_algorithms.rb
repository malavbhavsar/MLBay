class AddFileToAlgorithms < ActiveRecord::Migration
  def change
    add_column :algorithms, :file, :string
  end
end
