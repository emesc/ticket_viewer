class Ticket
  def initialize
    @page = 0
  end

  def first_page(tickets)
    paginate("first_page")
    render_tickets(tickets)
  end

  def next_page(tickets)
    paginate("next")
    render_tickets(tickets)
  end

  def prev_page(tickets)
    paginate("prev")
    render_tickets(tickets)
  end

  def page(tickets, num)
    paginate("page", num: num)
    render_tickets(tickets)
  end

  def show(tickets, id)
    ticket = tickets.find { |t| t["id"] == id }
    puts "<<< Showing ticket ID #{ticket['id']} >>>".center(135)
    output_table_header
    list(ticket)
    print "PRIORITY   : "
    puts ticket['priority'].nil? ? "-" : "#{ticket['priority']}"
    puts "DESCRIPTION: #{ticket['description']}"
    puts "<<< Type 'menu' to view options or 'quit' to exit >>>".center(135)
  end

  def paginate(option, args={})
    case option
    when "next"
      @page += 1
    when "prev"
      @page -= 1
    when "first_page"
      @page = 0
    when "page"
      @page = args[:num] - 1
    end
  end

  def render_tickets(tickets)
    output_options(tickets)
    output_table_header
    tickets[current_page(tickets)].each do |ticket|
      list(ticket)
    end
    output_options(tickets)
  end

  def current_page(tickets)
    @page % tickets.length
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

  def output_options(tickets)
    puts "<<< Showing page #{current_page + 1} of #{tickets.length} >>>".center(135)
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

  private
    def datetime_format(created_at)
      dt = DateTime.parse(created_at)
      local_dt = dt.new_offset(DateTime.now.offset)
      local_dt.strftime("%Y %b %d at %H:%M:%S")
    end
end
