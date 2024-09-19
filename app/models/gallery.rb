class Gallery < ApplicationRecord
  has_many :photos

  has_many_attached :images do |image|
    image.variant :titan_max, resize_to_limit: [2000, 2000]
  end

  after_create_commit :create_photo_embedding

  private

  def create_photo_embedding
    BedrockService.perform(type: 'image', photo_id: id)
  end
end
