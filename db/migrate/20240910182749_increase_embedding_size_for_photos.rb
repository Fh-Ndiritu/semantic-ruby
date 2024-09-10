class IncreaseEmbeddingSizeForPhotos < ActiveRecord::Migration[7.1]
  def change
    change_column :photos, :embedding, :vector, limit: 1024
  end
end
