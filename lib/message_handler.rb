# frozen_string_literal: true

require_relative 'quotes_service'
require_relative 'photos_service'

class MessageHandler
  COMMANDS = {
    '/start' => :start,
    '/stop'  => :stop,
    '/foto'  => :photo,
    '/frase' => :quote
  }.freeze

  def initialize(bot)
    @bot = bot
    @photos = PhotosService.new
  end

  attr_reader :bot, :photos

  def handle(message)
    method = COMMANDS[message.text] || :fallback
    send(method, message)
  end

  private

  def start(message)
    text = I18n.t('start_message', message.from.to_h)
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end

  def stop(message)
  end

  def photo(message)
    bot.api.send_chat_action(chat_id: message.chat.id, action: 'upload_photo')
    bot.api.send_photo(chat_id: message.chat.id, photo: photos.generate)
  end

  def quote(message)
    bot.api.send_chat_action(chat_id: message.chat.id, action: 'typing')
    response = QuotesService.generate
    bot.api.send_message(
      chat_id: message.chat.id, text: response.text, parse_mode: 'Markdown'
    )
  end

  def fallback(message)
    text = I18n.t('fallback_message', message.from.to_h)
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end
end
