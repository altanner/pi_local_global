#!/usr/bin/env python

import time
import subprocess
import scrollphathd

print("""
Scroll pHAT HD: Advanced Scrolling

Advanced scrolling example which displays a message line-by-line
and then skips back to the beginning.

Press Ctrl+C to exit.
""")

# Uncomment the below if your display is upside down
#   (e.g. if you're using it in a Pimoroni Scroll Bot)
scrollphathd.rotate(degrees=180)

# Dial down the brightness
scrollphathd.set_brightness(0.2)

# If rewind is True the scroll effect will rapidly rewind after the last line
rewind = True

# Delay is the time (in seconds) between each pixel scrolled
delay = 0.002 # originally 0.03

def get_lines():
    global lengths
    global lines
    global line_height
    lines = []
    with open ('/home/pi/weather/conditions', 'r') as conditions:
        lines = conditions.read().splitlines()
    print(lines)    
    # Determine how far apart each line should be spaced vertically
    line_height = scrollphathd.DISPLAY_HEIGHT + 2

    # Store the left offset for each subsequent line (starts at the end of the last line)
    offset_left = 0

    # Draw each line in lines to the Scroll pHAT HD buffer
    # scrollphathd.write_string returns the length of the written string in pixels
    # we can use this length to calculate the offset of the next line
    # and will also use it later for the scrolling effect.
    lengths = [0] * len(lines)

    for line, text in enumerate(lines):
        lengths[line] = scrollphathd.write_string(text, x=offset_left, y=line_height * line)
        offset_left += lengths[line]

    # This adds a little bit of horizontal/vertical padding into the buffer at
    # the very bottom right of the last line to keep things wrapping nicely.
    scrollphathd.set_pixel(offset_left - 1, (len(lines) * line_height) - 1, 0)

get_lines()
counter = 0
while counter < 15:
#    if counter == 3:
 #       subprocess.call("/home/pi/weather/get_conditions.sh")
  #      get_lines()
   #     counter = 0
    # Reset the animation
    scrollphathd.scroll_to(0, 0)
    scrollphathd.show()

    # Keep track of the X and Y position for the rewind effect
    pos_x = 0
    pos_y = 0

    for current_line, line_length in enumerate(lengths):
        # Delay a slightly longer time at the start of each line
        time.sleep(delay*10)

        # Scroll to the end of the current line
        for y in range(line_length):
            scrollphathd.scroll(1, 0)
            pos_x += 1
            time.sleep(delay)
            scrollphathd.show()

        # If we're currently on the very last line and rewind is True
        # We should rapidly scroll back to the first line.
        if current_line == len(lines) - 1 and rewind:
            counter += 1
            for y in range(pos_y):
                scrollphathd.scroll(-int(pos_x/pos_y), -1)
                scrollphathd.show()
                time.sleep(delay)
            
        # Otherwise, progress to the next line by scrolling upwards
        else:
            for x in range(line_height):
                scrollphathd.scroll(0, 1)
                pos_y += 1
                scrollphathd.show()
                time.sleep(delay)
