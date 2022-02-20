# frozen_string_literal: true

require 'pastel'
require 'terminal-table'
require 'tty-prompt'

# Sharing common terminal related methods and data
module Terminalable
  private

  attr_accessor :pastel, :prompt

  def populate_terminalable
    self.prompt = TTY::Prompt.new
    self.pastel = Pastel.new
  end

  def prompt_say_alert(string)
    prompt.say(string, color: terminal_alert_color)
  end

  def prompt_say_message(string)
    prompt.say(string, color: terminal_message_color)
  end

  def prompt_say_table(&block)
    prompt.say(terminal_table(&block), color: terminal_table_color)
  end

  def terminal_table(&block)
    Terminal::Table.new(&block)
  end

  def terminal_alert_color
    pastel.red.bold.detach
  end

  def terminal_table_color
    pastel.cyan.detach
  end

  def terminal_message_color
    pastel.magenta.detach
  end
end
