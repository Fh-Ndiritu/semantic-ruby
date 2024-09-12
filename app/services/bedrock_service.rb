# frozen_string_literal: true

# interface with the Bedrock API
class BedrockService
  def initialize(type: 'text', **args)
    @client = Aws::BedrockRuntime::Client.new
    @type = type
    @query = args[:query]
    @photo = Photo.find(args[:photo_id]) if args[:photo_id]
  end

  def self.perform(**args)
    new(**args).perform
  end

  def perform
    request_params = case @type
                     when 'text'
                       build_search_request
                     when 'image'
                       build_image_request
                     end

    response = @client.invoke_model(request_params)
    data = JSON.parse(response.body.read)
    case @type
    when 'text'
      data['embedding']
    when 'image'
      update_photo_embedding(data['embedding'])
    end
  rescue StandardError => e
    puts "Error: #{e}"
  end

  private

  def build_search_request
    model_id = 'amazon.titan-embed-image-v1'
    body = {
      "inputText": @query,
      'embeddingConfig': {
        'outputEmbeddingLength': 1024
      }
    }.to_json

    { model_id:, body: }
  end

  def build_image_request
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

  def base64_encoded_image
    image = @photo.image.variant(:titan_max).processed
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
