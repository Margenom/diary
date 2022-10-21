#!/usr/bin/tclsh
# more v0.5: System for keep diary and more 
# Copyright (C) 2022 Daniil Shvachkin <margenom at ya dot ru>
# Released under the terms of the GNU General Public License version 2.0

### Command Line Input
set CLI_PARAMS [list]; 
set CLI_ARGS [list]
# arg pair or param is -t -time -trap=no (QEMU stile), but no -trap yes
foreach p $argv { if [regexp -- {^-([^=]+)(?:=(.+))?$} $p all pname pval] { 
	lappend CLI_PARAMS [list $pname $pval] 
} else { lappend CLI_ARGS $p} }

# if count_optional <0 then unlimit optional arguments
proc args_check {require optional {offset 1}} { global CLI_ARGS
	set alen [expr [llength $CLI_ARGS] - $offset]
	return  [expr !(($alen >= $require) && (($alen <= ($optional + $require)) || ($optional < 0)))] 
}
# req_params is list of names required params
proc params_check pamlist { set bpam 1; global CLI_PARAMS
	foreach p $CLI_PARAMS { 
		set bpam [expr $bpam && ([lsearch -index 0 $CLI_PARAMS $p] != -1)] 
	}
	return $bpam
}

# param or value
proc pam {name {orval false} {convert 0} {empty_val true}} {
	global CLI_PARAMS
	set val [lsearch -index 0 -inline $CLI_PARAMS $name]
	if [string eq $val ""] { return $orval } else { set val [lindex $val 1]
		if [string eq $convert 0] { 
			if [string eq $val ""] { return $empty_val} else { return $val}
		} else { return [$convert $val]}
	}
}


# About
set ABOUT "" 
proc about-include {name about {def ""} {defhum ""}} { global ABOUT; global CLI_PARAMS
	set mval [pam $name ""]
	if [string eq $mval ""] { 
		if [string eq $def ""] { set ln "-$name=<$about>"
		} else { if [string eq $defhum ""] {set df $def} else {set df $defhum}
			set ln "\[-$name=<$about, def '$df'>\]" 
			lappend CLI_PARAMS [list $name $def] }
	} else { set ln "-$name=$mval"}
	set ABOUT "$ABOUT\t$ln\n"
}
proc about-command {usage about} { global ABOUT; set ABOUT "$ABOUT\t\t$about\n\t$usage\n"; }
proc about-switch {categ} { global ABOUT; set ABOUT "$ABOUT$categ\n"; }

# configuration
about-switch {Configuration params (no config files) }
about-include home "here your collections: records, cats, files. logs" 
proc myhome {mypath} { return [file join [pam home] $mypath]}
about-include record-type {record type search patern} {(?:^|.*/)\d{9,11}$}
proc myfiles {type {usefiles {}}} {
	if {$usefiles != {}} {set files $usefiles} else {
		set files [glob -tails -directory [pam home] *]}
	return [lsearch -all -inline -regexp $files $type]
}
#about-include "category-type" 
proc mycat_story {cat data line} {
	variable catfile
	if {$line < 0} { set catfile [open [myhome $cat] a] 
		puts $catfile $data 
	} else {
		set catfile [open [myhome $cat] r+]
		for {set ln 0} {$ln < $line} {incr ln} { gets $catfile
			if [eof $catfile] { puts "Out of lines category"; break } }
		set catoffset [tell $catfile]
		set catoff [read $catfile]
		seek $catfile $catoffset
		puts $catfile $data
		puts -nonewline $catfile $catoff }
	close $catfile
}
about-include "listext" "list file extention" ls
about-include "timescan" "format for time scaning" "%Y%m%d%H%M"
proc mytimescan {timeline} { return [clock scan $timeline -format [pam timescan]]}
about-include "timeformat" "use while printing"	"%a %d.%m (%Y) %H:%M {%s}"
proc mytime {timesec} { return [clock format $timesec -format [pam timeformat]]}
about-include "show-rules" "rules how interpritate cat line" {
	{{regexp [pam record-type] $ln} {return "==> [mytime $ln]\n[read-exec "cat [myhome $ln]"]"}}
	{{regexp [types-ext {text txt}] $ln name ext} {return "==> $ln\n[read-exec "cat [myhome $ln]"]"}}
	{{expr 1} {return "=-=> $ln"}}}
proc myshow {ln} {
	proc read-exec {command} {
		set pipe [open [linsert $command 0 {|}] r]
		set out [read $pipe]
		close $pipe
		return $out
	}
	proc types-ext {ext-list} { return "^(.*)\\.([join ${ext-list} "|"])\$" }

	foreach rule [pam show-rules] {
		if [eval [lindex $rule 0]] {
			return [eval [lindex $rule 1]]
		}
	}
}

# commands
set COMMANDS [list]

# if count_optional <0 then unlimit optional arguments
proc command-collect {name require optional usage body descr} { global COMMANDS
	lappend COMMANDS [list $name $require $optional $body]
	about-command $usage $descr
}

proc command-exec {fail} { global COMMANDS; global CLI_ARGS
	set cmd [lsearch -index 0 $COMMANDS [lindex $CLI_ARGS 0]]
	if {$cmd == -1} $fail 

	set cmd [lindex $COMMANDS $cmd]
	set require [lindex $cmd 1]
	set optional [lindex $cmd 2]
	set offset 1
	set alen [expr [llength $CLI_ARGS] - $offset]
	set args [expr ($alen >= $require) && (($alen <= ($optional + $require)) || ($optional < 0))] 

	# arguments data
	set data [lrange $CLI_ARGS 1 end]

	# execute command
	if {$args} [lindex $cmd 3] $fail
}

about-switch "Commands"

command-collect more 0 0 {more [-t=<time, se -timescan def now>|-u=<utime, unix time>] [-e=<editor, def EDITOR>]} {
	exec >@stdout 2>@stderr [pam e $::env(EDITOR)] [myhome [pam t [pam u [clock seconds]] mytimescan]]
} {create record}

command-collect safe 2 0 {safe <file> <cat> [-r=<row of cat, def end>]} {
	set name [file tail [lindex $data 0]]
	mycat_story [lindex $data 1] $name [pam r -1]
	file copy [lindex $data 0] [myhome ""]
} {safe file into cat}

command-collect app 2 0 {app <data> <cat> [-r=<row>]} {
	mycat_story [lindex $data 1] [lindex $data 0] [pam r -1]
} {app line of data into cat}

command-collect show 1 0 {show <cat> [-n line numeration] [-l=<limit>] [-p=<pager>] } {
	set pager [open "|[pam p $::env(PAGER)]" w]
	set lim [pam l -1]
	set catfile [open [myhome [lindex $data 0]] r]
	while {[gets $catfile ln] >= 0} {
		if [string eq [pam n 0] ""] {puts -nonewline $pager "#$lim "}
		puts $pager "[myshow $ln]\n" 
		if {!$lim} {break} ; incr lim -1
	}
	close $catfile
	close $pager 
}  {show records in category (rules can control interpritation line)}

command-collect last 0 1 {last [<cat>, else show last] [-l=<record>] [-r=<row>]} {
	set last [pam l [lindex [lsort [myfiles [pam record-type]]] end]]
	if {$last == {}} {puts "No records in my base!" } else { 
		if [llength $data] {
			mycat_story [lindex $data 0] $last [pam r -1]
		} else { puts $last}
	}
} {add last record into cat or add record onto last of category}

command-collect member 0 0 {member [-tfrom=<-||->|-ufrom=<utime, def 0>] [-tto=<to, eq from def now>|-uto=<-||->] [-p=<pager>]} {
	set pager [open "|[pam p $::env(PAGER)]" w]
	set tfrom [pam tfrom [pam ufrom 0] mytimescan]
	set tto [pam tto [pam uto [clock seconds]] mytimescan]

	foreach rec [lsort [myfiles [pam record-type]]] { 
		if {$tfrom < $rec && $tto > $rec} { puts $pager [myshow $rec]}
	}
	close $pager 
} {show records from diary use <viewer> without files and cats}

command-collect log 1 -1 {log <log file> <descr part 0> .. <part n> [-t=<time>|-u=<utime>]
	log <log file> [-p=<pager, def cat>] [-h hide date] } {

	set logfile [myhome "[lindex $data 0].[pam listext]"]
	set msgline [lrange $data 1 end]
	if {![llength $msgline]} { 
		if {![file readable $logfile]} {
			puts "No find $logfile."
			exit
		}
		set lfs [open $logfile r]
		set pager [open "|[pam p cat]" w]
		set hide_date [pam h false]
		while {[gets $lfs ln] > 0} {
			if [regexp {^(\d+)\t(.+)$} $ln all time mesg] {
				if {!$hide_date} {puts -nonewline $pager "[mytime $time]\t" }
				puts $pager $mesg
			}
		}
		close $lfs
		close $pager
	} else { puts [open $logfile a] "[pam t [pam u [clock seconds]] mytimescan]\t$msgline" }
} {add record to timestamped list, or show it}

### check required params (Configuration)
proc help-gen {} {global ABOUT; puts $ABOUT; exit}
if [params_check home] {helo-gen}
command-exec {help-gen; exit}
