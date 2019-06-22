require 'socket'
class Server
  def initialize(ip_v4, port)
    @server = TCPServer.new ip_v4, port
    @connections = Hash.new
    loop do
      puts "waiting for client"
      client = @server.accept
      request = client.gets
      lines = receive(request)
      if (!lines.nil?)
        if (lines.key?("Broadcaster") && !lines["Broadcaster"].nil?)
          @connections[lines["Broadcaster"]] = Hash.new
          Thread.start(client) do |client|
            current_user = lines["Broadcaster"].freeze
            puts "Current User: #{current_user}-----------"
            loop do
              puts 'Waiting on new data---------'
              song_info = client.readpartial(2048)
              song_info = receive song_info
              if (!song_info.nil?)
                if (song_info.key?("Song_id") && song_info.key?("Duration") && !song_info["Duration"].nil? && !song_info["Song_id"].nil?)
                  @connections[current_user] = ["Song_id" => song_info["Song_id"], "Duration" => song_info["Duration"]]
                  puts @connections[current_user]
                else
                  puts "Bad Song Data"
                end
              else
                puts "No Song Data"
              end
            end
          end
        else
          puts "Bad Broadcaster Data..."
        end
      else
        puts "Broadcaster Data is null"
      end
    end
  end

  def receive(lines)
    info = Hash.new
    lines = reorderLines(lines)
    lines.each_line do |line|
      contents = line.strip!.split(":")
      info[contents[0]] = contents[1]
    end
    return info
  end

  def reorderLines(lines)
    new_lines = ""
    lines.each_line do |f|
      if (f.strip!.length == 0 || f.include?("------"))
        next
      else
        new_lines += f
        new_lines += "\n"
      end
    end
    return new_lines
  end

end