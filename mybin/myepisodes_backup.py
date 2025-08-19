#!/usr/bin/env python

import getpass
import os
import sys

from lxml import html

file_path = "~/Downloads/index.html"

# Can't log in and download it from here because we won't clear CloudFlare checks in headless mode.
# Current workaround: download the html from the browser and then run the script to get a csv

if os.path.exists(file_path):
	with open(file_path, "r") as file:
		root = html.fromstring(file.read())
else:
	sys.exit(f"Download the unfiltered All-In-One and save as {file_path}")

if len(root.forms[1].form_values()) < 5:
	sys.exit("The index.html file doesn't have all filters checked")

table = root.xpath('//table')[2]

SEPARATOR = ','

with open('myep_backup.csv','w') as file:
	header = f'TITLE{SEPARATOR}LAST EPISODE{SEPARATOR}IGNORED?\n'
	file.write(header)

	# Skip header
	for row in table[1:]: 
		title = row[1][0].text_content()
		last = row[2][0].text_content().lstrip().rstrip()
		ignored = "false"
		if len(row[1]) > 1:
			ignored = "true"

		show = f'{title}{SEPARATOR}{last}{SEPARATOR}{ignored}\n'
		file.write(show)
