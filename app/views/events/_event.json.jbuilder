json.extract! event, :id, :date, :theme, :description, :organization_id, :created_at, :updated_at
json.url event_url(event, format: :json)
