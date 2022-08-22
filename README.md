# disctiption
Simple program for manage diary with categories (with web viewer) and boxing planing.

# usage (application name self)
time format: [MMDD]hhmm
utime sample: 1658945725
length format: (\d+[smhdw]?)
	sec, min, hour, day, week or sec 

self conv <utime>
	to hummanity time
self conv <time>
	to unix time

self app <list> [-t time] [-<name> <val>] <some...>
	app record into list <list>
self list [-name [val]] <list> 
	print content of list

self [-p port]
	run web application for view records and cat's and steps
	!optionaly i want add some function for grep, sort and write records, but now use grep and cat
	! and i want add upload and download files from/into cat using web ui

	# diary
self more [time]
	make record into diary
self last <cat> 
	add last record in diary into <cat>
self safe <cat> <file>
	add <file> name into <cat> and copy <file> into main diary dir

	# boxing planing
self step [-b begin,time] [-l length] [-<name> <param>] <description...>
	store step into base, step consist from: time begin, length (in sec), (named params) and
	description (about this step
self stats [-d diff, how ago] [-<name> [<param>], for grep by <param>] [-t(by time if exists or times)]
[-p period, print percent (time or times) for <param>'ed step from mase in period]
	print list of activity from (now - diff) to now

self box [-t time] [-<name> <val>] <length> <name> <description>
self clip [-t time] [-l deadline or length] <name,box> [<cicle> or current]  [<comment>]
	if box this <name> unexist and -l used is create new box and clip it
self finish <name,box>
	in current cicle also make `self step ..,`
self loses [<cicle>]
	print cicle, what fail, what pass, what will be fail /*optimism ya ya*/

# objects
record - just text file named like utime, no formated and without extention [\d{11}]
cat - file what store in each line name of file from base [\w+]
spec - files with extentions, that also stored into cat [[^.]+.\w]

list - spec *.l DSV(\t) like {utime}\t[{name}*val\t]<some..., text>\n

step - list with specific functional
box - list like step, different in <name>*<length> - first param of named values
cicle - argegate squerias of box what must be done in current period (week or more)
	is folder this sml files, named like "\d+" from begin (now ~= <begin> + period * <name>) 
