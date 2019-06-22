#receives input. stores it.
require 'socket'
class Server
  private

  @server = nil

  def initialize (ip_v4, port)
    @ip_v4 = ip_v4
    @port = port
    @server = TCPServer.new ip_v4, port
    @client = nil
    loop do
      puts 'waiting....'
      @client = @server.accept
      request = @client.readpartial(2048)
      # puts request
      request_info = parse(request.to_s)
      if (request_info.key?("User_id"))
        resp = "<html>amit</html>"
        puts "We have confirmation that the machine has been reached."
        headers = ["HTTP/1.1 200 OK",
                   "Access-Control-Allow-Origin: *\r\n",
                   "Date: Tue, 14 Dec 2010 10:48:45 GMT",
                   "Server: Ruby",
                   "Content-Type: text/html; charset=iso-8859-1",
                   "Content-Length: #{resp.length}\r\n\r\n", "Content: asdf \r\n"].join("\r\n")
        @client.puts headers
        @client.puts "asdf"
        @client.close
        @socket = TCPSocket.open('192.168.1.91', 4445)
        send_id(request_info["User_id"])
        loop do
          puts "waiting for next byte..."
          client = @server.accept
          info = client.readpartial(2048)
          # puts info
          parsed_info = receive info
          client.close
          send_off parsed_info["Duration"], parsed_info["Song_id"]
        end
      else
        @client.close
        puts "reality is often disappointing"

      end
    end
  end

  def send_id(id)
    if @socket
      puts "sent it out: #{id}"
      @socket.puts("Broadcaster:#{id}")
    else
      puts "Socket it null"
    end
  end

  def send_off(duration, song_id)
    if @socket
      @socket.puts "Duration:#{duration} \nSong_id:#{song_id}"
      puts "sent off"
    else
      puts "socket is nil"
    end
  end

  def receive(lines)

    info = Hash.new
    lines = reorderLines(lines)
    lines.each_line do |line|
      contents = line.split(":")
      info[contents[0]] = contents[1]
    end
    unless !info["Duration"] || !info["Song_id"]
      puts "Current Song Duration: #{info["Duration"]}"
      puts "Current Song Id: #{info["Song_id"]}"
      return info
    else
      puts "one is null"
    end
  end

  def reorderLines(lines)
    puts "reordering...."
    new_lines = ""
    lines.each_line do |f|
      if (f.strip!.length == 0 || f.include?("------"))
        next
      elsif f.include?("Content-Disposition: form-data; ")
        f = f.gsub "Content-Disposition: form-data; name=", ""
        f = f.gsub "\"", ""
        new_lines += f
        new_lines += ":"
      else
        new_lines += f
        new_lines += "\n"
      end
    end
    return new_lines
  end

  def parse(request)
    request = reorderLines(request)
    info = Hash.new
    request.to_s.each_line do |f|
      contents = f.split(":")
      info[contents[0]] = contents[1]
    end
    if info.key "Broadcaster"
      return nil
    end
    return info
  end

  def is_number?(obj)
    obj.to_f.to_s == obj.to_s || obj.to_i.to_s == obj.to_s
  end

end

