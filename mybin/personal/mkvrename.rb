#!/usr/bin/env ruby

##
# Iterates through the mkv files in a given directory, storing the file's name as the title property of the mkv

raise 'Need a directory' if ARGV.empty?

begin
  dir = File.realpath(ARGV[0])
rescue Errno::ENOENT
  warn "Directory '#{ARGV[0]}' does not exist"
  exit 1
end

Dir["#{dir}/**/*.mkv"].each do |d|
  puts `mkvpropedit "#{d}" -e info -s title="#{File.basename(d, '.mkv')}"`
end
