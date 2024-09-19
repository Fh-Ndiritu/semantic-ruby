class Search < ApplicationRecord
  has_neighbors :embeddings
  has_one_attached :image do |image|
    image.variant :titan_max, resize_to_limit: [2000, 2000]
  end
end
