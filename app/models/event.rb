# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :organization
  has_many_attached :images do |image|
    image.variant :titan_max, resize_to_limit: [1200, 1200]
  end

  after_save_commit :create_image_embedding

  private

  def create_image_embedding
    BedrockJob.perform_async(type: 'event_update', id:)
  end
end
