# frozen_string_literal: true

class AttachmentEmbedding < ApplicationRecord
  belongs_to :blob, class_name: 'ActiveStorage::Blob'
end
