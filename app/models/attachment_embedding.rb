# frozen_string_literal: true

class AttachmentEmbedding < ApplicationRecord
  include CosineSimilaritySearch
  has_neighbors :embedding
  belongs_to :blob, class_name: 'ActiveStorage::Blob'
end
