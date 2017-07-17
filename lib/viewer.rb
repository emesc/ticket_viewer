require "readline"

require_relative "client"

class Viewer
  def initialize
    Client.new
  end

  def connect
    introduction
    conclusion
  end

  def introduction
    puts "\nWelcome to the ticket viewer"
    puts "Type 'menu' to view options or 'quit' to exit"
    print "> "
  end

  def conclusion
    puts "\nThank you for using the viewer. Goodbye"
  end
end
