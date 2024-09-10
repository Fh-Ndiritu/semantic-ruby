class CreateGalleries < ActiveRecord::Migration[7.1]
  def change
    create_table :galleries do |t|
      t.string :title
      t.text :description
      t.datetime :event_date

      t.timestamps
    end
  end
end
