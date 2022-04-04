require 'cupsffi'

class Printer
  def self.print(id)
    new(id).print
  end

  def initialize(id)
    @id = id
  end

  def print
    job = printer.print_data(text, "text/plain", options)
    loop do
      puts job.status
      break unless [:pending, :processing].include?(job.status)
      sleep 1
    end
    tweet.update(printed: true) if job.status == :completed
  end

  private

  def tweet
    @tweet ||= Tweet.find(@id)
  end

  def message
    [tweet.username, "said on", tweet.tweeted_at, ":", tweet.content].join(" ")
  end

  def printer
    # printers = CupsPrinter.get_all_printer_names
    # Brother_QL_810W
    @printer ||= CupsPrinter.new("Brother_QL_810W")
  end

  def options
    {
      'cupsPrintQuality': 'High',
      'MediaType': 'roll',
      'PageSize': "Custom.#{width}x#{height}mm"
    }
  end

  def width
    62
  end

  def height
    (text_array.size * 7).to_i
  end

  def text_array
    message.scan(/(.{1,22})(?:\s|$)/m)
  end

  def text
    "\r\n #{text_array.join("\r\n ")}".encode(
      "ascii",
      invalid: :replace,
      undef: :replace,
      replace: ''
    )
  end
end
