# Google Voice Texts Converter

## Description
Google Voice exports its text messages in an HTML format, one HTML file per day of messages. This format can be extremely inconvenient for viewing an entire texting history. This script addresses this issue by stripping out all relevant text message data from these HTML files, formatting it, and compiling it into one continuous texting history file, saved as a single TXT file.

## Usage
To use this script effectively:

1. Export Text message history from Google Voice.
2. Unzip the downloaded file.
3. Navigate to the `Takeout/Voice/Calls` folder.
4. Filter by Text Messages only (e.g., `ls *Text*.html`).
5. Identify the Phone Number or Contact Name of interest (e.g., `ls *Tom*Text*.html`).
6. Create a new directory for sorting.
7. Copy (do not move) the relevant files to the new directory (e.g., `cp *Tom*Text*.html NewFolder`).
8. Move this script into the new folder.
9. Execute the script. It will find every HTML file, compile the data in chronological order, and save it to `compiled_texts_{timestamp}.txt`.
10. You can then safely move the `compiled-texts.txt` file to a different location and delete the new folder and its contents.

## Dependencies
Ensure that your Linux environment has the following tools installed:
- sed
- grep
- cut
- cat

## Notes
This script is currently compatible with the Google Voice export format as of 2024-02-11. If future versions of Google Voice change their export format, the script may require adjustments.

## Author
Code Correct

## Last Modified
2024-02-12
