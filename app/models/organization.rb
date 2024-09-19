class Organization < ApplicationRecord
  has_many :events, dependent: :destroy

  def images
    events.map(&:images).flatten
  end
end
