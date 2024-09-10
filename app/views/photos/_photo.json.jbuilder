json.extract! photo, :id, :title, :location, :description, :image, :gallery_id, :created_at, :updated_at
json.url photo_url(photo, format: :json)
json.image url_for(photo.image)
