# frozen_string_literal: true

# interface with the Bedrock API
class BedrockService
  SYSTEM_RAG_PROMPT = '
  <instructions>
  You shall be given vector embeddings of various images. Use only images to answer the user query.
  Take your time to understand the images, analyze the user query and provide a response.
  Do not mention the images in the output but use them to generate your answer.
  Remember to keep the output relevant to the user query and use the images.
  Include your answer in the <output> tag.
  </instructions>'
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
    elsif @type == 'search'
      perform_search_request
    else
      perform_rag_request
    end
  rescue StandardError => e
    puts "Error: #{e}"
  end

  private

  def perform_search_request
    request_params = build_search_request
    data = fetch_bedrock_response(request_params)
    update_search_embedding(data['embedding'])
  end

  def perform_rag_request
    request_params = build_rag_request
    response = fetch_bedrock_response(request_params)
    response.dig('content', 0, 'text').gsub('</output>', '').strip
  end

  def vectorize_images
    event = Event.find_by(id: @params[:id])
    return unless event

    event.images.each do |image|
      request_params = build_image_request(image)
      data = fetch_bedrock_response(request_params)
      update_image_embedding(image, data['embedding'])
    end
    true
  end

  def fetch_bedrock_response(request_params)
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
    attach_image_or_text(body)

    { model_id:, body: body.to_json }
  end

  def build_rag_request
    model_id = 'anthropic.claude-3-haiku-20240307-v1:0'
    content = build_images_content
    content << { type: 'text', text: @params[:query] }

    body = {
      "anthropic_version": 'bedrock-2023-05-31',
      system: SYSTEM_RAG_PROMPT,
      max_tokens: 2000,
      temperature: 0.5,
      messages: [
        {
          role: 'user',
          content:

        },
        { role: 'assistant', content: '<output>' }
      ]
    }.to_json
    { model_id:, body: }
  end


  def build_images_content
    @params[:blob_ids].map do |blob_id|
        {
          "type": "image",
          "source": {
              "type": "base64",
              "media_type": "image/jpeg",
              "data": base64_encoded_image(ActiveStorage::Attachment.find_by(blob_id:))
          }
      }
    end
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
    body.merge!('inputImage' => base64_encoded_image(@search.image)) if @search.image.attached?
    body.merge!('inputText' => @search.query) if @search.query.present?
  end

  def update_search_embedding(embedding)
    return unless @search.update(embedding:)

    embedding
  end
end
