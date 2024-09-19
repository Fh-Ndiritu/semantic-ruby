class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.datetime :date
      t.string :theme
      t.text :description
      t.belongs_to :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
