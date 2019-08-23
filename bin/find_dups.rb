#!/usr/bin/env ruby

#
# Prints pairs of duplicated files in the directory the file is executed from
#

require 'digest/sha1'

duplicates = Dir["*"].reject { |e| File.directory? e }
                     .group_by { |e| Digest::SHA1.hexdigest File.read(e) }
                     .select { |k, v| v.size > 1 }
                     .values

puts duplicates
