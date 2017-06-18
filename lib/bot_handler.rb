# frozen_string_literal: true

require_relative 'message_handler'

class BotHandler
  def initialize(bot)
    @bot = bot
    @message_handler = MessageHandler.new(bot)
  end

  def handle(message)
    return send_message('unauthorized_message', message) unless authorized?(message.from)

    case message
    when Telegram::Bot::Types::Message
      @message_handler.handle(message)
    end
  rescue => ex
    STDERR.puts ex
    send_message('generic_error_message', message)
  end

  private

  def authorized?(user)
    users = ENV['AUTHORIZED_USERS'].split(',')
    users.include?(user.username)
  end

  def send_message(type, message)
    text = I18n.t(type, message.from.to_h)
    @bot.api.send_message(chat_id: message.chat.id, text: text)
  end
end