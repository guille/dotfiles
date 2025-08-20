#!/usr/bin/env ruby

##
# Iterates over all the PDF files in the current directory (and subdirectories) and
# renames them to include the number of pages in the filename.
# Requires `pdfinfo`

require 'shellwords'

Dir['**/*.pdf'].each_with_index do |file, idx|
  next if file.end_with?(' pp).pdf')

  puts "(idx: #{idx}) Processing #{file}"

  pages = `pdfinfo #{Shellwords.escape(file)} | awk '/^Pages:/ {print $2}'`.strip

  new_filename = file.sub('.pdf', " (#{pages} pp).pdf")
  File.rename(file, new_filename)
rescue Errno::ENOENT
  puts 'This program requires `pdfinfo` to function'
  exit 1
end
