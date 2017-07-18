require "readline"
require "pry"
require_relative "client"

class Viewer
  attr_accessor :client, :tickets, :page
  def initialize
    @client = Client.new
    @tickets = []
    @page = 0
    # @tickets_count = 0
  end

  def menu
    puts "Select view options"
    puts "*Type 'load'      to connect to the api and retrieve the tickets"
    puts "*Type 'next'      to view the next page of tickets"
    puts "*Type 'prev'      to view the previous page of tickets"
    puts "*Type 'show <id>' to view a ticket"
    puts "*Type 'quit'      to exit"
  end

  def load
    puts "Retrieving tickets..."
    @tickets = @client.all_tickets
    puts "Done."
    if @tickets.empty?
      puts "Failed to connect to the api. Type 'load' to try again."
    else
      output_options
      output_table_header
      @tickets[current_page].each do |ticket|
        list(ticket)
      end
    end
    @tickets
  end

  # def tickets_total
  #   @tickets_count = @tickets.inject(0) { |len, ary| len + ary.length }
  # end

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
    end
  end

  def list(ticket)
    item_line = "| " << ticket["id"].to_s.rjust(3)
    item_line << " | " + ticket["subject"].ljust(60)
    item_line << " | " + ticket["requester_id"].to_s.ljust(14)
    item_line << " | " + ticket["created_at"].to_s.ljust(30) + " |"
    puts item_line
    puts "-" * 120
  end

  def introduction
    puts "\nWelcome to the ticket viewer"
    puts "Type 'menu' to view options or 'quit' to exit"
    print "> "
  end

  def conclusion
    puts "\nThank you for using the viewer. Goodbye"
  end

  def output_options
    puts
    puts "<<< Showing page #{current_page + 1} >>>".center(120)
    puts "<<< Type 'menu' to view options or 'quit' to exit >>>".center(120)
  end

  def output_table_header
    puts "-" * 120
    print "| " + "ID".rjust(3) + " |"
    print " " + "Subject".ljust(60) + " |"
    print " " + "Requester".ljust(14) + " |"
    print " " + "Created on".ljust(30) + " |\n"
    puts "-" * 120
  end
end

# v = Viewer.new
# v.load
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

