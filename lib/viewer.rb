require "readline"
require "pry"
require_relative "client"

class Viewer
  attr_accessor :client, :tickets, :page
  def initialize
    @client = Client.new
    @tickets = []
    @tickets_flat = []
    @page = 0
    launch
  end

  def launch
    introduction
    result = ""
    until result == :quit
      command, args = get_command
      result = do_command(command, args)
    end
    conclusion
  end

  def get_command
    puts
    print "> "
    user_command = gets.chomp.downcase.strip
    args = user_command.split(" ")
    action = args.shift
    return action, args
  end

  def do_command(action, args=[])
    case action
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
      page(num)
    when 'show'
      id = args.shift
      show(id)
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
    else
      @page = num.to_i - 1
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
    item_line << " | " + ticket["created_at"].to_s.ljust(30) + " |"
    puts item_line
    puts "-" * 135
  end

  def flatten_tickets
    @tickets_flat = @tickets.flatten
  end

  def show(id)
    if @tickets.empty?
      puts "Please type 'load' to retrieve the tickets"
    else
      ticket = @tickets_flat.find { |t| t["id"] == id.to_i }
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
    puts "\nWelcome to the ticket viewer"
    puts "Type 'menu' to view options or 'quit' to exit"
  end

  def conclusion
    puts "\nThank you for using the viewer. Goodbye"
  end

  def output_options
    puts "<<< Showing page #{current_page + 1} >>>".center(135)
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
end

Viewer.new
# v.load
# v.show(101)
# v.show(75)
# v.show(1)
# v.prev_page
# v.next_page
# v.next_page
# v.prev_page
# v.prev_page
# v.prev_page
# v.prev_page
# v.prev_page
# v.prev_page
# v.next_page
# v.next_page
# v.next_page
# v.next_page
# v.next_page
# v.next_page
# v.next_page

