# frozen_string_literal: true

class CreateAttachmentEmbeddings < ActiveRecord::Migration[7.1]
  def change
    create_table :attachment_embeddings do |t|
      t.references :blob, null: false, foreign_key: { to_table: :active_storage_blobs }
      t.vector :embedding, limit: 1024
      t.timestamps
    end
  end
end
