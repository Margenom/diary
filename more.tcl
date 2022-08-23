#!/usr/bin/tclsh
#constants
set Myhome "$::env(HOME)/me"

#about
proc myhelp {} { puts { Program for catalogized diary
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
			r records, 
			f plan text, 
			i image, 
			b blob or binary
	show <cat> [-n numbers of lines, def no num] [-l=<limit>]
			[-p=<viewer, def PAGER>] [-i=<include>] 
		show records from diary use <viewer> without files and cats
	member [-f=<from, time>] [-t=<to, eq from>] [-p=<pager>]
		run interactive ui on tk or web
	~ui
~ - no realise now} 
	exit 
}
#functions
# param or value
proc param_or_val {name orval {convert 0}} {
	global params
	set val [lsearch -index 0 -inline $params $name]
	if [string eq $val ""] { return $orval
	} else { set val [lindex $val 1]
		if [string eq $convert 0] { return $val} else { return [$convert $val]}
	} 
}
# if count_optional <0 then unlimit optional arguments
# req_params is list of names required params
proc args_require {data params count_require count_optional req_params} {
	set bpam 1
	foreach p $req_params {
		set pam [lsearch -index 0 $params $p]
		set bpam [expr $bpam && ($pam != -1)]
	}
	set alen [llength $data]
	set barg [expr ($alen >= $count_require) && (($alen <= ($count_optional + $count_require)) || ($count_optional < 0))]
	if [expr !($barg && $bpam)] {myhelp}
}
#myfunctions
proc mytime {timeline} { return [clock scan $timeline -format {%Y%m%d%H%M}]}
proc myhome {mypath} { global Myhome ; return [file join $Myhome $mypath]}
proc mycat_story {cat data {line -1}} {
	variable catfile
	if {$line < 0} { set catfile [open [myhome $cat] a]; puts $catfile $data
	} else { set catfile [open [myhome $cat] r+]
		for {set ln 0} {$ln < $line} {incr ln} {
			gets $catfile
			if [eof $catfile] { puts "Out of lines category"; break }
		}
		set catoffset [tell $catfile]
		set catoff [read $catfile]
		seek $catfile $catoffset
		puts $catfile $data
		puts -nonewline $catfile $catoff
	}
	close $catfile
}
proc mycat_show {catname limit rules} { set catfile [open [myhome $catname] r]
	set out ""
	set lim 0
	while {[gets $catfile ln] >= 0} {
		set t 1
		foreach r $rules {if [regexp [lindex $r 0] $ln] {
			append out [[lindex $r 1] $ln]
			set t 0
			break
		}}
		if {$t} {append out $ln} 
		append out "\n" 
	}
	close $catfile
	return $out
}
proc myfiles_list {type {usefiles {}}} {
	global files 
	set pfiles $files
	if {$usefiles != {}} {set pfiles $usefiles}
	return [lsearch -all -inline -regexp $pfiles $type]
}
proc Tshow_recs {rname} {set fp [open [myhome $rname] r]
	set tm [clock format $rname -format "\n==> %a %d.%m (%Y) %H:%M\n"]
	append tm [read $fp]
	close $fp
	return $tm
}
set Types_recs {(?:^|.*/)\d{9,11}$}

#global temperary
set files [lsort [glob -tails -directory $Myhome *]]

#globals
set params [list]
set other [list]
# arg pair is -t -time -trap=no, but no -trap yes
foreach p $argv {
	if [regexp -- {^-([^=]+)(?:=(.+))?$} $p all pname pval] {
		lappend params [list $pname $pval]
	} else { lappend other $p}
}
set mode [lindex $other 0]
set data [lrange $other 1 end]

switch $mode {
	more {exec >@stdout 2>@stderr [param_or_val e $::env(EDITOR)] [myhome [param_or_val t [clock seconds] mytime]]}
	safe {args_require $data $params 2 0 {}
		set name [file tail [lindex $data 0]]
		mycat_story [lindex $data 1] $name
		file copy [lindex $data 0] [myhome ""]}
	last {args_require $data $params 1 0 {}
		set recs [myfiles_list $Types_recs]
		set last ""
		if [string eq "" $recs] { puts "No records in my base!" } else { set last [lindex [lsort $recs] end] }
		set last [param_or_val l $last]
		if [string eq "" $last] {exit}
		mycat_story [lindex $data 0] $last }
	app {args_require $data $params 2 0 {}
		mycat_story [lindex $data 1] [lindex $data 0] [param_or_val l -1]}
	show {args_require $data $params 1 0 {}
		set include [param_or_val i "p"]
		set moders [list]
		for {set m 0} {$m < [string length $include]} {incr m} {
			switch [string index $include $m] {
				p {lappend moders [list $Types_recs Tshow_recs]}
				default {break}}}
		set pager [open [concat "|" [param_or_val p $::env(PAGER)]] w]
		puts $pager [mycat_show [lindex $data 0] [param_or_val l -1] $moders ] 
		close $pager }
	member { set pager [open [concat "|" [param_or_val p $::env(PAGER)]] w]
		set tfrom [param_or_val f 0 mytime]
		set tto [param_or_val f [clock seconds] mytime]
		foreach rec [lsort [myfiles_list $Types_recs]] {
			if {$tfrom < $rec && $tto > $rec} {puts $pager [Tshow_recs $rec]}}
		close $pager }
	default {myhelp}
}
