#!/usr/bin/tclsh
#constants
set Myhome "/tmp"

#about
proc myhelp {} { puts { Program for catalogized diary
		create record
	more [-t=<time, def now>] [-e=<editor, def EDITOR>]
		safe file into cat
	safe <file> <cat>
		add last record into cat
		or add record onto last of category
	last <cat> [-l=<record>]
		app file or record or somepfing into cat, combination
	~app <line> <cat> [-l=<line>]
		read categoryes use tk or PAGER
		include, def -i=r eq records only, more
			r record, 
			f files, 
			i image, 
			b blob
	~show <cat> [-l=<limit>] [-v=<viewer, def PAGER or tk>] [-i=<include] 
		show records from diary use <viewer> without files and cats
	~member [-f=<from, data(time)>] [-t=<to, eq from>] [-v=<viewer>]
		run interactive ui on tk
	~gui
~ - no realise now} 
	exit 
}
#functions
proc myhome {mypath} {
	global Myhome
	return "$Myhome/$mypath"
}
proc file_name {path} {
	set sep_path [file split $path]
	return [lindex $sep_path [expr [llength $sep_path] - 1]]
}
proc file_list {type {use_files 0}} {
	global files
	return [lsearch -all -inline -regexp type [expr $use_files? $use_files: $files]]
}
set Types_recs {\d{9,11}}
# param or value
proc param_or_val {name orval} {
	global params
	set val [lsearch -index 0 -inline $params $name]
	if [string eq $val ""] { return $orval
	} else { return [lindex $val 1] }
}
# if count_optional <0 then unlimit optional arguments
# req_params is list of names required params
proc args_require {data params count_require count_optional req_params} {
	set bpam 1
	foreach p $req_params {
		set pam [lsearch -index 0 $params $p]
		set bpam [expr $bpam && ($pam != -1)]
	}
	set alen [llength data]
	set barg [expr ($alen >= $count_require) && (($alen <= ($count_optional + $count_require)) || ($count_optional < 0))]
	if [expr !($barg && $bpam)] {myhelp}
}

#global temperary
set files [lsort [glob -directory $Myhome *]]

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
	more {puts [concat [param_or_val e $::env(EDITOR)] [myhome [param_or_val t [clock seconds]]]]}
	safe {args_require $data $params 2 0 {}
		set name [file_name [lindex $data 0]]
		mycat_story [lindex $data 1] $name
		puts [concat "cp -r" [lindex $data 0] [myhome $name]]}
	last {args_require $data $params 1 0 {}
		set last [param_or_val l [lindex [lsort [myfiles_list $Types_recs]] 0]]
		mycat_story [lindex $data 0] $last }
	default {myhelp}
}
