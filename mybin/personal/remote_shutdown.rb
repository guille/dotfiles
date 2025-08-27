#!/usr/bin/env ruby

# Turns off the PC when receiving a request on port 8081

require 'socket'

puts 'Listening on port 8081'

server = TCPServer.new(8081)

loop do
  request = server.accept
  `systemctl poweroff`
  request.close
end
