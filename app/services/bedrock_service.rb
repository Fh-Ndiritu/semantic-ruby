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
    request_params = @type == 'image' ? build_image_request : build_search_request

    response = @client.invoke_model(request_params)
    data = JSON.parse(response.body.read)

    @type == 'search' ? data['embedding'] : update_photo_embedding(data['embedding'])
  rescue StandardError => e
    puts "Error: #{e}"
  end

  private

  def build_image_request
    @photo = Photo.find(@params[:photo_id])
    model_id = 'amazon.titan-embed-image-v1'
    body = {
      "inputText": build_photo_tags,
      'inputImage': base64_encoded_image,
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
    body.merge!('inputImage' => base64_encoded_image(@search)) if @search.image.attached?
    body.merge!('inputText' => @search.query) if @search.query.present?
    body = body.to_json

    { model_id:, body: }
  end

  def base64_encoded_image(klass = @photo)
    image = klass.image.variant(:titan_max).processed
    Base64.strict_encode64(image.download)
  end

  def build_photo_tags
    tags = []
    tags << @photo.title
    tags << @photo.description
    tags << @photo.gallery.title
    tags << @photo.gallery.description
    tags << @photo.gallery.event_date
    tags << @photo.location
    tags.join(' ')
  end

  def update_photo_embedding(embedding)
    @photo.embedding = embedding

    return if @photo.save

    puts "Error: Unable to save photo embedding for photo id: #{@photo_id}"
    puts @photo.errors.full_messages
  end
end
