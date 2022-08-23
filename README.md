 Program for catalogized diary
		create record
	more [-t=<time, YYYYMMDDhhmm def now>] [-e=<editor, def EDITOR>]
		safe file into cat
	safe <file> <cat>
		add last record into cat
		or add record onto last of category
	last <cat> [-l=<record>]
		app line of data into cat	
	app <data> <cat> [-l=<line of cat, def end>]
		read categoryes use tk or PAGER
		include, def -i=r eq records only, more
			r record, 
			f files, 
			i image, 
			b blob
	~show <cat> [-n numbers of lines, def no num] [-l=<limit>]
			[-v=<viewer, def PAGER>] [-i=<include] 
		show records from diary use <viewer> without files and cats
	~member [-f=<from, data(time)>] [-t=<to, eq from>] [-v=<viewer>]
		run interactive ui on tk or web
	~ui
~ - no realise now
