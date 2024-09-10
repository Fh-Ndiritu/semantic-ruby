json.extract! gallery, :id, :title, :description, :event_date, :photos, :created_at, :updated_at
json.url gallery_url(gallery, format: :json)
json.photos do
  json.array!(gallery.photos) do |photo|
    json.id photo.id
    json.url url_for(photo)
  end
end
