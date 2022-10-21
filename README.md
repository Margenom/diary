# Tips to usage: configuration store in bashrc as alias
	and no edit records like in real diary (utime in name help you)
	categories need for defenition diffirent types of diary

# Program for catalogized diary

		create record
	more [-t=<time, se -timescan def now>|-u=<utime, unix time>] [-e=<editor, def EDITOR>]
		safe file into cat
	safe <file> <cat> [-r=<row of cat, def end>]
		app line of data into cat
	app <data> <cat> [-r=<row>]
		show records in category (rules can control interpritation line)
	show <cat> [-n line numeration] [-l=<limit>] [-p=<pager>] 
		add last record into cat or add record onto last of category
	last [<cat>, else show last] [-l=<record>] [-r=<row>]
		show records from diary use <viewer> without files and cats
	member [-tfrom=<-||->|-ufrom=<utime, def 0>] [-tto=<to, eq from def now>|-uto=<-||->] [-p=<pager>]
		add record to timestamped list, or show it
	log <log file> <descr part 0> .. <part n> [-t=<time>|-u=<utime>]
	log <log file> [-p=<pager, def cat>] [-h hide date] 

# Configuration params (no config files)

	-home=<here your collections: records, cats, files. logs>
	[-record-type=<record type search patern, def '(?:^|.*/)\d{9,11}$'>]
	[-listext=<list file extention, def 'ls'>]
	[-timescan=<format for time scaning, def '%Y%m%d%H%M'>]
	[-timeformat=<use while printing, def '%a %d.%m (%Y) %H:%M {%s}'>]
	[-show-rules=<rules how interpritate cat line, def '
	{{regexp [pam record-type] $ln} {return "==> [mytime $ln]\n[read-exec "cat [myhome $ln]"]"}}
	{{regexp [types-ext {text txt}] $ln name ext} {return "==> $ln\n[read-exec "cat [myhome $ln]"]"}}
	{{expr 1} {return "=-=> $ln"}}'>]

