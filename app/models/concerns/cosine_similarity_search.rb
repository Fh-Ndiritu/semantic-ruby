# frozen_string_literal: true

# performs cosine search and appends items with score ranks
module CosineSimilaritySearch
  extend ActiveSupport::Concern

  included do
    attr_accessor :similarity
  end

  class_methods do
    def cosine_similarity_search(query_embedding, limit)
      # how much space does the vector occupy?
      query_magnitude = vector_magnitude(query_embedding)

      items_with_similarity = all.map do |item|
        item_embedding = item.embedding
        similarity = cosine_similarity(query_embedding, item_embedding, query_magnitude)
        item.similarity = similarity
        item
      end

      # Sort items by similarity score in descending order
      items_with_similarity.sort_by { |item| - item.similarity }.take(limit)
    end

    private

    # Calculate the cosine similarity between two vectors (query and product)
    def cosine_similarity(vector_a, vector_b, vector_a_magnitude)
      # a*b/(||a||*||b||)  ==> dot_product/magnitudes
      dot_product = dot_product(vector_a, vector_b)
      vector_b_magnitude = vector_magnitude(vector_b)

      # Avoid division by zero
      return 0 if vector_a_magnitude.zero? || vector_b_magnitude.zero?

      dot_product / (vector_a_magnitude * vector_b_magnitude)
    end

    # Compute the dot product of two vectors - How much do they align/point in same direction (scalar)
    # a*b =|a|b|cos(O)
    def dot_product(vector_a, vector_b)
      vector_a.zip(vector_b).map { |a, b| a * b }.sum
    end

    # Compute the magnitude (Euclidean norm) of a vector - Pythagorean theorem in x(1024) dimensions
    def vector_magnitude(vector)
      Math.sqrt(vector.map { |x| x**2 }.sum)
    end
  end
end
