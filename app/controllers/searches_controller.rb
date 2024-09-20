# frozen_string_literal: true

class SearchesController < ApplicationController
  def new
  end

  def create
    redirect_to root_path unless params[:query] || params[:image]
    @query = params[:query]

    search = Search.new(query: @query, image: params[:image])
    redirect_to root_path unless search.save

    @results = fetch_similarity_results(search)
    return unless @query.present? && @results.present?

    blob_ids = @results.take(5).map(&:blob_id)
    @output = BedrockService.perform(type: 'rag', blob_ids:, query: @query)
  end

  private

  def fetch_similarity_results(search)
    if (embedding = BedrockService.perform(type: 'search', search_id: search.id))
      AttachmentEmbedding.cosine_similarity_search(embedding, 7)
    else
      []
    end
  end
end
