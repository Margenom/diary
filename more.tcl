#!/usr/bin/tclsh
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
	foreach p $CLI_PARAMS { set pam [lsearch -index 0 $CLI_PARAMS $p]; set bpam [expr $bpam && ($pam != -1)] }
	return $bpam
}

# param or value
proc pamVal {name {orval false} {convert 0}} {
	global CLI_PARAMS
	set val [lsearch -index 0 -inline $CLI_PARAMS $name]
	if [string eq $val ""] { return $orval } else { set val [lindex $val 1]
		if [string eq $convert 0] { return $val} else { return [$convert $val]}
	}
}

### general functions
proc myhome {mypath} { return [file join [pamVal home] $mypath]}
proc mytime {timesec} { return [clock format $timesec -format [pamVal timeformat]]}
proc mytimescan {timeline} { return [clock scan $timeline -format [pamVal timescan]]}
proc myhelp {} {global ABOUT; puts $ABOUT; exit}

# About
set ABOUT {Program for catalogized diary
		create record
	more [-t=<time, se -timescan def now>|-u=<utime, unix time>] [-e=<editor, def EDITOR>]
		create video record
#	video [-t=<time>|-u=<utime>] [-c=<record command format>] [<message>]
		create audio record
#	audio [-t=<time>|-u=<utime>] [-c=<record command format>] [<message>]
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
	log <log file> [-p=<pager, def cat>]

Configuration params (no config files)
}
proc about-include {name about {def ""} {defhum ""}} { global ABOUT; global CLI_PARAMS
proc opt? {cont} {upvar def def; if [string eq "" $def] {return $cont} else {return "\[$cont\]"}}
proc app {val} {return ", now is $val"}
	set mval [pamVal $name ""]
	if [string eq $mval ""] { 
		if [string eq $def ""] { set ABOUT "$ABOUT\t-$name=<$about>\n"
		} else { if [string eq $defhum ""] {set df $def} else {set df $defhum}
			set ABOUT "$ABOUT\t[opt? "-$name=<$about, def \"$df\">"]\n" 
			lappend CLI_PARAMS [list $name $def] }
	} else { set ABOUT "$ABOUT\t-$name=$mval\n"}
}

about-include "home" "here your collections: records, cats, files. logs" 
set tmf [list png jpg jpeg gif webp]
about-include "imgs" "list of image exts" $tmf [join $tmf ","]
set tmf [list txt md html htm]
about-include "text" "list of text exts" $tmf [join $tmf ","]
about-include "listext" "list file extention" ls
about-include "timescan" "format for time scaning" "%Y%m%d%H%M"
about-include "timeformat" "use while printing"	"%a %d.%m (%Y) %H:%M {%s}"
#about-include "home-rec" "here located records" [myhome] 
#about-include "home-safe" "here located files, else for recs and logs make link" [myhome]
#about-include "home-logs" "here located logs" [myhome] 
#about-include "home-cat" "here located cats" [myhome] 
#about-include "home-audio" "here located audio recs" [myhome] 
#about-include "mediaabout" "location file, what collect message about media files" [myhome "/.about"]
#about-include "form-rec" "format audio records" "%s"
#about-include "form-audio" "format audio records" "%s.ogg"
#about-include "form-video" "format video records" "%s.ogv"
unset tmf

### check required params (Configuration)
if [params_check home] {myhelp}

### special functions
proc myfiles_list {type {usefiles {}}} {
	set files [lsort [glob -tails -directory [pamVal home] *]]
	set pfiles $files
	if {$usefiles != {}} {set pfiles $usefiles}
	return [lsearch -all -inline -regexp $pfiles $type]
}

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

proc mycat_show {catname limit numbers rules mode} { set catfile [open [myhome $catname] r]
	set out ""
	set lim 0
	while {[gets $catfile ln] >= 0} {
		if [string eq $numbers ""] {append out "#$lim "}
		set t 1
		foreach r $rules {if [regexp [lindex $r 0] $ln] {
			append out [[lindex $r 1] $ln $mode]
			set t 0
			break }}
		if {$t} {append out $ln} 
		append out "\n" 
		if {$lim == $limit} {break}
		incr lim
	}
	close $catfile
	return $out
}

# web mod
proc Whead {cont} {return "<h4>$cont</h4>"}
proc Wtext {cont} {return "<pre>$cont</pre>"}

### type specifed
set Trecs {(?:^|.*/)\d{9,11}$}
proc showTrec {name mode} {set fp [open [myhome $name] r]; switch $mode {
	2 { set out "[Whead [mytime $name]][Wtext [read $fp]]"}
	1 { set out [read $fp]}
	default { set out "==> [mytime $name]\n[read $fp]"}}
	close $fp
	return $out
}

set Ttext_types [pamVal text]
set Ttext "^(.*)\\.([join Ttext_types "|"])\$" 
proc showTtext {name mode} {set fp [open [myhome $name]]; switch $mode {
	2 { set out "[Whead "File $name"][Wtext [read $fp]]"}
	1 { set out [read $fp]}
	default { set out "==> $name\n[read $fp]\n"}}
	close $fp
	return $out
}

set Timg_types [pamVal imgs]
set Timg "^(.*)\\.([join Timg_types "|"])\$" 
proc showTimg {name mode} {set fp [open [myhome $name]]; switch $mode {
	2 { package require base64
	if [regex Timg $name all iname itype] {
		set out "<img src='data:image/$itype;base64,[base64::encode [read $fp]]' alt='$iname'/>"}}
	1 { set out [read $fp] }
	default { set out "Image $name"}}
	close $fp
	return $out
}

### main
proc argsVhelp {req opt} {if [args_check $req $opt] {myhelp}}

set data [lrange $CLI_ARGS 1 end]
switch [lindex $CLI_ARGS 0] {
	more {exec >@stdout 2>@stderr [pamVal e $::env(EDITOR)] [myhome [pamVal t [pamVal u [clock seconds]] mytimescan]]}
	safe {argsVhelp 2 0
		set name [file tail [lindex $data 0]]
		mycat_story [lindex $data 1] $name [pamVal r -1]
		file copy [lindex $data 0] [myhome ""]}
	last {argsVhelp 1 0
		set recs [myfiles_list $Trecs]
		set last ""
		if [string eq "" $recs] { puts "No records in my base!" } else { set last [lindex [lsort $recs] end] }
		set last [pamVal l $last]
		if [string eq "" $last] {exit}
		mycat_story [lindex $data 0] $last [pamVal r -1]}
	app {argsVhelp 2 0
		mycat_story [lindex $data 1] [lindex $data 0] [pamVal r -1]}
	show {argsVhelp 1 0
		# text view, raw view, html view
		set mode 0 	
		set moders [list]
		set include [pamVal i "r"]
		for {set m 0} {$m < [string length $include]} {incr m} {
			switch [string index $include $m] {
				r {lappend moders [list $Trecs showTrec]}
				i {lappend moders [list $Timg showTimg]; if {!$mode} {set mode 2}}
				f {lappend moders [list $Ttext showTtext]}
				b {lappend moders [list $Tblobs showTblobs]; set mode 1}
				default {break}}}
		set pager [open "|[pamVal p [lindex [list $::env(PAGER) cat "w3m -T text/html"] $mode]]" w]
		puts $pager [mycat_show [lindex $data 0] [pamVal l -1] [pamVal n 0] $moders $mode] 
		close $pager }
	member { set pager [open "|[pamVal p $::env(PAGER)]" w]
		set tfrom [pamVal tfrom [pamVal ufrom 0] mytimescan]
		set tto [pamVal tto [pamVal uto [clock seconds]] mytimescan]
		foreach rec [lsort [myfiles_list $Trecs]] { if {$tfrom < $rec && $tto > $rec} {puts $pager [showTrec $rec 0]}}
		close $pager }
	log {argsVhelp 1 -1
		set logfile [myhome "[lindex $data 0].[pamVal listext]"]
		if {![args_check 1 0]} { 
			set lfs [open $logfile r]
			set pager [open "|[pamVal p cat]" w]
			while {[gets $lfs ln] > 0} {
				if [regexp {^(\d+)\t(.+)$} $ln all date mesg] {
					puts $pager "[mytime $date]\t$mesg"
				}
			}
			close $lfs
			close $pager
			exit
		}
		puts [open $logfile a] "[pamVal t [pamVal u [clock seconds]] mytimescan]\t[lrange $data 1 end]"}
	default {myhelp}
}
