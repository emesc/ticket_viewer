require "readline"
require "pry"

require_relative "client"
require_relative "ticket"

class Viewer
  attr_accessor :client, :tickets, :page
  attr_reader :ticket

  COMMANDS = ["menu", "load", "next", "prev", "page", "show", "quit"]

  def initialize
    @client = Client.new
    @ticket = Ticket.new
    @tickets = []
    @tickets_flat
    @page = 0
  end

  def launch
    introduction
    result = nil
    until result == :quit
      command, args = get_command
      result = do_command(command, args)
    end
    conclusion
  end

  def get_command
    puts
    command = nil
    until COMMANDS.include?(command)
      puts "I don't understand that command" if command
      user_command = user_input("> ")
      args = user_command.downcase.split(" ")
      command = args.shift
    end
    return command, args
  end

  def do_command(command, args=[])
    case command
    when 'quit'
      :quit
    when 'menu'
      menu
    when 'load'
      load
    when 'page'
      num = args.shift.to_i
      @ticket.page(@tickets, num) if valid_page?(num)
    when 'show'
      id = args.shift.to_i
      @ticket.show(@tickets_flat, id) if valid_ticket_id?(id)
    else
      invalid?(@tickets) ? load_reminder : Ticket.send(command, @tickets)
    end
  end

  def valid_page?(num)
    if invalid?(@tickets)
      load_reminder
      return false
    elsif !(1..@tickets.length).include? num
      puts "Please enter page number between 1 and #{@tickets.length}"
      return false
    else
      return true
    end
  end

  def valid_ticket_id?(id)
    if invalid?(@tickets)
      load_reminder
      return false
    elsif !(1..@tickets_flat.length).include? id
      puts "Ticket not found"
      return false
    else
      return true
    end
  end

  def load
    puts "Retrieving tickets..."
    @tickets = @client.all_tickets
    flatten_tickets if !invalid?(@tickets)
    puts "Done. Your request returned #{@tickets_flat.length} tickets on #{@tickets.length} pages.\n\n"
    invalid?(@tickets) ? reconnect_reminder : @ticket.first_page(@tickets)
    @tickets
  end

  def invalid?(tickets)
    (tickets.empty? || @tickets.all?(&:nil?)) ? true : false
  end

  def flatten_tickets
    @tickets_flat = @tickets.flatten
  end

  def load_reminder
    puts "Please type 'load' to retrieve the tickets"
  end

  def reconnect_reminder
    puts "Failed to connect to the api. Type 'load' to try again."
  end

  def menu
    puts "View options"
    puts "*Type 'load'      to connect to the api and retrieve the tickets"
    puts "*Type 'next'      to view following page of tickets"
    puts "*Type 'prev'      to view previous  page of tickets"
    puts "*Type 'page <no>' to view specific  page of tickets"
    puts "*Type 'show <id>' to view specific  ticket"
    puts "*Type 'quit'      to exit"
  end

  def introduction
    puts "<<< Welcome to the ticket viewer >>>".center(135)
    puts "<<< Type 'menu' to view options or 'quit' to exit >>>".center(135)
  end

  def conclusion
    puts "<<< Thank you for using the viewer. Goodbye >>>".center(135)
  end

  def user_input(prompt="")
    prompt ||= "> "
    input = Readline.readline(prompt, true)
    input.strip
  end
end
