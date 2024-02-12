#!/bin/bash

# ------------------------------------------------------------------------------------------------------------
# Script Name: googlevoice-texts-converter.sh
# Author: Code Correct
# Date Created: 2024-02-11
# Last Modified: 2024-02-12
# Source: https://github.com/codecorrect/googlevoice-texts-converter
#
# Description: 
# 	Google Voice exports its texts messages in an HTML format, one HTML file per day of messages. 
#	This is an extremely inconvenient way to look at an entire texting history.
#	This script will strip out all of the relevant text message data, format it, and compile it into 
#	one continuous texting history file. Saved as a single TXT file. 
#
# Usage: 
# 	This script works off of the current working directory that the script is currently in, on every single 
# 	HTML file in the current folder. So we will need to isolate only the HTML files for the single texting
# 	conversation that we are wanting to compile. 
#	
#	Actions:
# 		- Export Text message history from Google Voice
# 		- Unzip the file downloaded
# 		- Go into the Takeout/Voice/Calls folder.
#		- Sort by Text Messages only. Ex: ls *Text*.html
#		- Find the Phone Number or Contact Name that you're interested in. Ex: ls *Tom*Text*.html
#		- Make a new directory for doing the sorting.
#		- Copy ONLY those files (don't move them) we're interested in to the new directory. 
#		  Ex: cp *Tom*Text*.html NewFolder
#		- Move into this new folder and copy this script into the new folder.
#		- Execute this script. It will automatically find every HTML file and compile the data in 
#		  cronological order and save it to compiled-texts.txt.
#		- Its now safe to move this text file to somewhere outside the current directory. Then
#		  you can delete the new folder and its contents (that were copied no moved). 
#
# Dependencies: 
# 	- Linux
# 	- sed
#	- grep 
#	- cut
#	- cat
#
# Notes:
# 	This works on the current Google Voice export as of the date this script was written.
# 	If future versions of Google Voice export differs in its format, then this script may 
# 	need some tweaking to get to function properly. 
#
# ------------------------------------------------------------------------------------------------------------



#converts month name to dec number
convert_month() {
	sed -e 's/Jan/1/' -e 's/Feb/2/' -e 's/Mar/3/' -e 's/Apr/4/' -e 's/May/5/' -e 's/Jun/6/' \
	    -e 's/Jul/7/' -e 's/Aug/8/' -e 's/Sep/9/' -e 's/Oct/10/' -e 's/Nov/11/' -e 's/Dec/12/'
}

#converts date format to YYYY-MM-DD
convert_date() {
	while read -r line; do
		local date_string=$(echo "$line" | awk '{print $1, $2, $3}')
		
		local day=$(echo "$date_string" | awk '{print $2}' | sed 's/,//g')
		local month=$(echo "$date_string" | awk '{print $1}' | sed 's/,//g' | convert_month)
		local year=$(echo "$date_string" | awk '{print $3}' | sed 's/,//g')

		local new_date=$(printf "[%04d:%02d:%02d" $year $month $day)
		echo "$line" | sed "s/$date_string/$new_date/"
	done
}

#converts time to 24h format
convert_time() {
	while read -r line; do
		local time_string=$(echo "$line" | grep -oE '[0-9]{1,2}:[0-9]{2}:[0-9]{2} [AP]M')

		local am_pm=$(echo "$time_string" | grep -oE '(AM|PM)')
		local hour=$(echo "$time_string" | cut -d: -f1)
		local minute=$(echo "$time_string" | cut -d: -f2)
		local second=$(echo "$time_string" | cut -d: -f3 | cut -d' ' -f1)

		#remove leading zero & treat as dec
		hour=$((10#$hour))
		minute=$((10#$minute))
		second=$((10#$second))

		if [ "$am_pm" = "PM" ] &&  [ "$hour" -ne 12 ]; then
			hour=$(($hour + 12))
		elif [ "$am_pm" = "AM" ] && [ "$hour" -eq 12 ]; then
			hour=0
		fi

		new_time=$(printf "%02d:%02d:%02d]" $hour $minute $second)
		echo "$line" | sed "s/$time_string/$new_time/"
	done
}



#main
#prints a banner
echo -e "\n==========================================="
echo "   GoogleVoice Texts - Compliation Script   "
echo "==========================================="
echo -e "\n Processing HTML files: \n"



#loops through every HTML file in curr dir
for file in *.html; do
	echo "Processing File: $file..."	
	if [ -e "$file" ]; then
		grep -E 'class="message"|class="sender vcard"|<q>' "$file" | 	#finds lines with text message data 
		sed 's/<[^>]*>//g' | 						#strips HTML tags
		sed "s/&#39;/'/g" | 		#converts apostrophe char ref
		sed 's/&#8239;/ /g' | 						#converts html whitespace ref to a space
		sed "s/&amp;/\&/g" |		#converts apersand char ref
		awk '{								#combines every 3 lines into 1
			if (NR % 3 == 1) {
				line = $0;
			} else if (NR % 3 == 2) {
				line = line " " $0;
			} else {
				print line " " $0;
			}
		}' |  
		sed 's/^[ \t]*//' | 		#strips leading whitespace
		convert_date | 
		convert_time >> gv_texts_compiled_$(date +"%Y-%m-%d").txt
	else
		echo "No HTML files found."
		exit 1
	fi
done

echo -e "\n\nTexts compilation complete. File saved as 'compiled_texts_$(date +"%Y-%m-%d").txt'"
