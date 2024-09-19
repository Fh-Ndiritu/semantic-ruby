# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :organization
  has_many_attached :photos
end
