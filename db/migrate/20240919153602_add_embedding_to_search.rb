# frozen_string_literal: true

class AddEmbeddingToSearch < ActiveRecord::Migration[7.1]
  def change
    add_column :searches, :embedding, :vector, limit: 1024
  end
end
