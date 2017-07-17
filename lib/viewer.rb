require "readline"

require_relative "client"

class Viewer
  def initialize
    Client.new
  end

  def connect
    introduction
    menu
    conclusion
  end

  def menu
    puts "Select view options"
    puts "*Type 'next'      to view the next page of tickets"
    puts "*Type 'prev'      to view the previous page of tickets"
    puts "*Type 'show <id>' to view a ticket"
    puts "*Type 'quit'      to exit"
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
