# frozen_string_literal: true

class PhotosService
  def initialize
    @photos = list_photos
  end

  def generate
    photo = @photos.sample
    Faraday::UploadIO.new(photo, 'image/jpeg')
  end

  private

  def list_photos
    path = File.join(ENV['PHOTOS_PATH'], '*.jpg')
    Dir.glob(path)
  end
end