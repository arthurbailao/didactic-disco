# frozen_string_literal: true

require 'telegram/bot'
require 'i18n'
require_relative 'lib/bot_handler'

I18n.load_path = Dir['config/locales.yml']
I18n.locale = :'pt-BR'
I18n.backend.load_translations

opts = { logger: Logger.new($stderr) }
Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_API_TOKEN'], opts) do |bot|
  handler = BotHandler.new(bot)
  bot.listen do |message|
    handler.handle(message)
  end
end
