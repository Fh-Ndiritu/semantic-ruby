# frozen_string_literal: true

# interface with the Bedrock API
class BedrockService
  def initialize(**args)
    @client = Aws::BedrockRuntime::Client.new
    @type = args[:type]
    @params = args
  end

  def self.perform(**args)
    new(**args).perform
  end

  def perform
    if @type == 'event_update'
      vectorize_images
    else
      perform_search_request
    end
  rescue StandardError => e
    puts "Error: #{e}"
  end

  private

  def perform_search_request
    request_params = build_search_request
    data = fetch_embedding(request_params)
    update_search_embedding(data['embedding'])
    true
  end

  def vectorize_images
    event = Event.find_by(id: @params[:id])
    return unless event

    event.images.each do |image|
      request_params = build_image_request(image)
      data = fetch_embedding(request_params)
      update_image_embedding(image, data['embedding'])
    end
    true
  end

  def fetch_embedding(request_params)
    response = @client.invoke_model(request_params)
    JSON.parse(response.body.read)
  end

  def build_image_request(image)
    model_id = 'amazon.titan-embed-image-v1'
    body = {
      "inputText": build_image_tags(image),
      'inputImage': base64_encoded_image(image),
      'embeddingConfig': {
        'outputEmbeddingLength': 1024
      }
    }.to_json

    { model_id:, body: }
  end

  def build_search_request
    @search = Search.find(@params[:search_id])
    model_id = 'amazon.titan-embed-image-v1'
    body = {
      'embeddingConfig': {
        'outputEmbeddingLength': 1024
      }
    }
    body = attach_image_or_text(body).to_json

    { model_id:, body: }
  end

  def base64_encoded_image(image)
    image = image.variant(:titan_max).processed
    Base64.strict_encode64(image.download)
  end

  def build_image_tags(image)
    event = image.record
    tags = []
    tags << event.theme
    tags << event.description
    tags << event.date
    tags << event.organization.description
    tags << event.organization.title
    tags.join(' ')
  end

  def update_image_embedding(image, embedding)
    embedding_record = AttachmentEmbedding.find_or_initialize_by(blob: image.blob) do |record|
      record.embedding = embedding
    end
    return if embedding_record.save

    puts "Error: Unable to save image embedding for blob id: #{image.blob.id}"

    puts embedding_record.errors.full_messages
  end

  def attach_image_or_text(body)
    body = body.merge('inputImage' => base64_encoded_image(@search.image)) if @search.image.attached?
    body.merge('inputText' => @search.query) if @search.query.present?
  end

  def update_search_embedding(embedding)
    @search.update(embedding:)
  end
end
