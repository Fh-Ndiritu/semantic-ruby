# frozen_string_literal: true

class SearchesController < ApplicationController
  def new
  end

  def create
    redirect_to root_path unless params[:query] || params[:image]
    @query = params[:query]

    search = Search.new(query: @query, image: params[:image])
    redirect_to root_path unless search.save

    @results = if (embedding = BedrockService.perform(type: 'search', search_id: search.id))
                 AttachmentEmbedding.cosine_similarity_search(embedding, 10)
               else
                 []
               end
  end
end
