# frozen_string_literal: true

# This module is meant to facilitate input for the USRAVideo module
# Largely this means input validation
module Input
  def self.answer_percent
    loop do
      answer = user_input
      return answer if percent?(answer)

      puts "That is not a valid input. Don't forget the %. Please enter a percent, e.g. 30%."
    end
  end

  class << self
    private

    def user_input
      $stdin.gets.chomp
    end

    def percent?(val)
      /[0-9][0-9]%/.match? val # TODO: Probably should use a cleaner regex
    end
  end
end
