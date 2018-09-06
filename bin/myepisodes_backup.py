#! /bin/python
from lxml import html
import requests
import getpass

user = input('Username: ')
password = getpass.getpass('Password: ')

payload = {
	'username': user,
	'password': password
}

filters_on = {
	'status_filter[]': ['1','2','4','8','16']
}

filters_off = {
	'status_filter[]': ['1','2','4']
}


with requests.Session() as s:
	# Login
 	s.post('https://www.myepisodes.com/login/', data=payload)
 	# Show ignored and ended shows
 	r = s.post('https://www.myepisodes.com/allinone/', data=filters_on)
 	# Turn off last 2 filters
 	s.post('https://www.myepisodes.com/allinone/', data=filters_off)
 
    
root = html.fromstring(r.content)

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