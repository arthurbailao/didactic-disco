# frozen_string_literal: true

require 'oj'
require 'typhoeus'

class QuotesService
  Response = Struct.new(:text, :error)
  URL = 'https://api.forismatic.com/api/1.0/'.freeze

  PARAMS = {
    method: 'getQuote',
    format: 'json',
    lang: 'en'
  }.freeze

  class << self
    def generate
      res = Typhoeus.get(URL, params: PARAMS)
      body = Oj.load(res.body.gsub(/\\/, ''), symbol_keys: true)

      quote = format_quote(body[:quoteText])
      author = format_author(body[:quoteAuthor])

      Response.new("#{quote} #{author}", false)
    rescue => ex
      Response.new(I18n.t('error_to_get_quote'), true)
    end

    private

    def format_quote(quote)
      i18n_id = "quote_prefix_#{rand(3) + 1}"
      prefix = I18n.t(i18n_id)
      "#{prefix}\n*#{quote.strip}*"
    end

    def format_author(author)
      author = author.to_s.strip
      return author if author.empty?

      url = URI.escape("https://en.wikipedia.org/wiki/#{author}")
      "[#{author}](#{url})"
    end
  end
end
