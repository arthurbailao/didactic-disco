# frozen_string_literal: true

require 'oj'
require 'typhoeus'
require 'tempfile'
require 'securerandom'

class ImgurService
  extend Forwardable
  def_delegator :@tempfile, :unlink

  def initialize(subreddit)
    @subreddit = subreddit
    @tempfile = Tempfile.new(SecureRandom.uuid)
    @photo = nil
  end

  attr_reader :subreddit, :photo

  def generate
    photos = request_photos
    @photo = photos.sample
    load_photo(@photo)
    Faraday::UploadIO.new(@tempfile.path, @photo[:mimetype])
  end

  private

  def imgur_url
    "https://imgur.com/r/#{subreddit}/hot.json"
  end

  def request_photos
    response = Typhoeus.get(imgur_url, params: { json: true })
    body = Oj.load(response.body, symbol_keys: true)
    body[:data]
  end

  def load_photo(photo)
    request = Typhoeus::Request.new(photo_url(photo))
    request.on_headers do |response|
      raise "Request failed" if response.response_code != 200
    end
    request.on_body { |chunk| @tempfile.write(chunk) }
    request.on_complete { @tempfile.close }

    request.run
  end

  def photo_url(photo)
    ext = photo[:ext].gsub(/\?.*/, '')
    "https://i.imgur.com/#{photo[:hash]}#{ext}"
  end
end