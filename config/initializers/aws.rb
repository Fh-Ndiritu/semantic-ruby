Aws.config.update(
  region: ENV.fetch('AWS-REGION', 'eu-west-2'),
  credentials: Aws::Credentials.new(
    ENV.fetch('AWS_ACCESS_KEY_ID', ''),
    ENV.fetch('AWS_SECRET_ACCESS_KEY', '')
  )
)
