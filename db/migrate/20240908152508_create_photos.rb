class CreatePhotos < ActiveRecord::Migration[7.1]
  def change
    create_table :photos do |t|
      t.string :title
      t.string :location
      t.string :description
      t.belongs_to :gallery, null: false, foreign_key: true
      t.vector :embedding, limit: 3

      t.timestamps
    end
  end
end
