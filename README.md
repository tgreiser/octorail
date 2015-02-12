# Octorail

Configure and video map modular systems of LED strips using OPC / FadeCandy.

* Import/Export LED configuration data separate from Processing sketch
* Drag and drop video mapping (re-)configuration of your LED strips
* Enable your modular LED network swarm

You configure one or more LED drivers along with the attached pixels and assemble all your strips into a scene. Play videos mapped to the entire scene - gives dimension to your LED installations.

Fadecandy is a next generation LED driver that receives data over USB (possibly from a raspberry Pi). Multiple drivers can be coordinated via TCP/IP by OpenPixelControl (OPC). This means you can coordinate thousands of pixels in realtime over the network.

### Driver
A LED driver, such as Fadecandy. A Fadecandy has 8 channels, or rails (numbered 0-7 because coders like to count from zero), each which can support up to 64 pixels in sequential order.


### Rail
This is a connection for one or more strips, these strips all join together in order, forming a single virtual strip, or rail. A rail has a number, probably 0-7.

### Segment
This is a segment of LED strip, it can have 0 or more LED pixels. If 0, it is just an extension segment (coming soon). Segments belong to a rail, and also have a letter, which represents their position in the rail (0A, 0B, 0C, 1A, 1B, 1C, etc).

### Buttons

0-9 - load video files (only 0-1 are provided, put more .mov videos in data/)
 .  - create a circular test pattern
 /  - create a radar sweep test pattern
 *  - create the fadecandy "dot" example pattern

### Credits

Thanks to my partner Amanda for help and inspiration.

Developed by Tim Greiser as part of the LEDesic project.
https://github.com/tgreiser/ledesic

Video content (c) Colin Worf as part of LEDesic.

Thanks to Micah Scott of Scanlime/Fadecandy.
https://github.com/scanlime/fadecandy

Support open standards!
http://openpixelcontrol.org/
