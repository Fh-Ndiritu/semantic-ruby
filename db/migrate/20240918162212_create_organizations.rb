class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
