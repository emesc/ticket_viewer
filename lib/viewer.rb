require "readline"
require "pry"
require_relative "client"

class Viewer
  attr_accessor :client, :tickets, :page

  COMMANDS = ["menu", "load", "next", "prev", "page", "show", "quit"]

  def initialize
    @client = Client.new
    @tickets = []
    @tickets_flat = []
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
    when 'menu'
      menu
    when 'load'
      load
    when 'next'
      next_page
    when 'prev'
      prev_page
    when 'page'
      num = args.shift
      page(num.to_i)
    when 'show'
      id = args.shift
      show(id.to_i)
    when 'quit'
      :quit
    end
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

  def load
    puts "Retrieving tickets..."
    @tickets = @client.all_tickets
    flatten_tickets if @tickets
    puts "Done. Your request returned #{@tickets_flat.length} tickets on #{@tickets.length} pages.\n\n"
    if @tickets.empty?
      puts "Failed to connect to the api. Type 'load' to try again."
    else
      @page = 0
      output_options
      output_table_header
      @tickets[current_page].each do |ticket|
        list(ticket)
      end
      output_options
    end
    @tickets
  end

  def current_page
    @page % @tickets.length
  end

  def next_page
    if @tickets.empty?
      puts "Please type 'load' to retrieve the tickets"
    else
      @page += 1
      output_options
      output_table_header
      @tickets[current_page].each do |ticket|
        list(ticket)
      end
      output_options
    end
  end

  def prev_page
    if @tickets.empty?
      puts "Please type 'load' to retrieve the tickets"
    else
      @page -= 1
      output_options
      output_table_header
      @tickets[current_page].each do |ticket|
        list(ticket)
      end
      output_options
    end
  end

  def page(num)
    if @tickets.empty?
      puts "Please type 'load' to retrieve the tickets"
    elsif !(1..@tickets.length).include? num
      puts "Please enter page number between 1 and #{@tickets.length}"
    else
      @page = num - 1
      output_options
      output_table_header
      @tickets[current_page].each do |ticket|
        list(ticket)
      end
      output_options
    end
  end

  def list(ticket)
    item_line = "| " << ticket["id"].to_s.rjust(5)
    item_line << " | " + ticket["status"].ljust(10)
    item_line << " | " + ticket["subject"].ljust(60)
    item_line << " | " + ticket["requester_id"].to_s.ljust(14)
    item_line << " | " + datetime_format(ticket["created_at"]).ljust(30) + " |"
    puts item_line
    puts "-" * 135
  end

  def flatten_tickets
    @tickets_flat = @tickets.flatten
  end

  def show(id)
    if @tickets.empty?
      puts "Please type 'load' to retrieve the tickets"
    elsif !(1..@tickets_flat.length).include? id
      puts "Ticket not found"
    else
      ticket = @tickets_flat.find { |t| t["id"] == id }
      puts "<<< Showing ticket ID #{ticket['id']} >>>".center(135)
      output_table_header
      list(ticket)
      print "PRIORITY   : "
      puts ticket['priority'].nil? ? "-" : "#{ticket['priority']}"
      puts "DESCRIPTION: #{ticket['description']}"
      puts "<<< Type 'menu' to view options or 'quit' to exit >>>".center(135)
    end
  end

  def introduction
    puts "<<< Welcome to the ticket viewer >>>".center(135)
    puts "<<< Type 'menu' to view options or 'quit' to exit >>>".center(135)
  end

  def conclusion
    puts "<<< Thank you for using the viewer. Goodbye >>>".center(135)
  end

  def output_options
    puts "<<< Showing page #{current_page + 1} of #{@tickets.length} >>>".center(135)
    puts "<<< Type 'menu' to view options or 'quit' to exit >>>".center(135)
  end

  def output_table_header
    puts "-" * 135
    print "| " + "ID".rjust(5) + " |"
    print " " + "Status".ljust(10) + " |"
    print " " + "Subject".ljust(60) + " |"
    print " " + "Requester".ljust(14) + " |"
    print " " + "Created on".ljust(30) + " |\n"
    puts "-" * 135
  end

  def datetime_format(created_at)
    dt = DateTime.parse(created_at)
    local_dt = dt.new_offset(DateTime.now.offset)
    local_dt.strftime("%Y %b %d at %H:%M:%S")
  end

  def user_input(prompt="")
    prompt ||= "> "
    input = Readline.readline(prompt, true)
    input.strip
  end
end
