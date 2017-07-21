require_relative "client"

class Viewer
  def initialize
    @client = Client.new
    @tickets = []
    @tickets_flat = []
    @page = 0
  end

  def load
    puts "Please wait while I retrieve the tickets..."
    @tickets = @client.all_tickets
    flatten_tickets
    puts "Done.\n\n"
    first_page
    @tickets
  end

  def first_page
    valid?(@tickets) ? render_tickets(@tickets, "first") : reconnect_reminder
  end

  def next
    valid?(@tickets) ? render_tickets(@tickets, "next") : load_reminder
  end

  def prev
    valid?(@tickets) ? render_tickets(@tickets, "prev") : load_reminder
  end

  def page(num)
    valid?(@tickets) && valid_page?(num) ? render_tickets(@tickets, "page", num) : not_found_reminder
  end

  def show(id)
    if valid?(@tickets) && valid_id?(id)
      ticket = @tickets_flat.find { |t| t["id"] == id }
      puts "<<< Showing ticket ID #{ticket['id']} >>>".center(135)
      output_table_header
      list(ticket)
      print "PRIORITY   : "
      puts ticket['priority'].nil? ? "-" : "#{ticket['priority']}"
      puts "DESCRIPTION: #{ticket['description']}"
      puts "<<< Type 'menu' to view options or 'quit' to exit >>>".center(135)
    else
      not_found_reminder
    end
  end

  def not_found_reminder
    puts "Ticket/page not found"
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

  def render_tickets(tickets, action, num=nil)
    paginate(action, num)
    output_options
    output_table_header
    @tickets[current_page].each do |ticket|
      list(ticket)
    end
    output_options
  end

  def list(ticket)
    item_line = "| " << ticket["id"].to_s.rjust(5)
    item_line << " | " + ticket["status"].ljust(10)
    item_line << " | " + ticket["subject"].ljust(60)
    item_line << " | " + ticket["requester_id"].to_s.ljust(14)
    item_line << " | " + local_format(ticket["created_at"]).ljust(30) + " |"
    puts item_line
    puts "-" * 135
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

  def local_format(created_at)
    dt = DateTime.parse(created_at)
    local_dt = dt.new_offset(DateTime.now.offset)
    local_dt.strftime("%Y %b %d at %H:%M:%S")
  end

  private

    def flatten_tickets
      @tickets_flat = @tickets.flatten
    end

    def valid?(tickets)
      (tickets.empty? || @tickets.all?(&:nil?)) ? false : true
    end

    def valid_page?(num)
      (1..@tickets.length).include? num
    end

    def valid_id?(id)
      (1..@tickets_flat.length).include? id
    end

    def paginate(action, num)
      case action
      when "next"
        @page += 1
      when "prev"
        @page -= 1
      when "page"
        @page = num - 1
      else
        @page = 0
      end
    end

    def current_page
      @page % @tickets.length
    end
end
