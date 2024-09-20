class BedrockJob
  include Sidekiq::Job

  def perform(*args)
    BedrockService.perform(**args.first.symbolize_keys)
  end
end
