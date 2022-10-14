# Tips to usage: configuration store in bashrc as alias
	and no edit records like in real diary (utime in name help you)
	categories need for defenition diffirent types of diary

# Program for catalogized diary

		create record
	more [-t=<time, se -timescan def now>|-u=<utime, unix time>] [-e=<editor, def EDITOR>]
		safe file into cat
	safe <file> <cat> [-r=<row of cat, def end>]
		add last record into cat
		or add record onto last of category
	last <cat> [-l=<record>] [-r=<row>]
		app line of data into cat	
	app <data> <cat> [-r=<row>]
		include, def -i=r eq records only, more
			r records (pager PAGER), 
			f plan text (pager PAGER), 
			i image as base64 (pager w3m -T text/html), 
			a all as is (pager cat)
	show <cat> [-n line numeration] [-l=<limit>] [-p=<pager>] [-i=<include>] 
		show records from diary use <viewer> without files and cats
	member [-tfrom=<from, time def 0>|-ufrom=<utime>] [-html htmlmod] [-tto=<to, eq from def now>|-uto=<utime>] [-p=<pager>]
		add record to timestamped list
	log <log file> <descr part 0> .. <part n> [-t=<time>|-u=<utime>]
		show record from timestamped list (log)
	log <log file> [-p=<pager, def cat>] [-h hide date]

# Configuration params (no config files)

	-home=<here your collections: records, cats, files. logs>
	[-imgs=<list of image exts, def "png,jpg,jpeg,gif,webp">]
	[-text=<list of text exts, def "txt,md,html,htm">]
	[-listext=<list file extention, def "ls">]
	[-timescan=<format for time scaning, def "%Y%m%d%H%M">]
	[-timeformat=<use while printing, def "%a %d.%m (%Y) %H:%M {%s}">]

