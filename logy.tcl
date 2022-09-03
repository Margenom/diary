#!/usr/bin/tclsh

set WorkDir [info script]
if [string eq [file type $WorkDir] link] { set WorkDir [file readlink $WorkDir] }
set WorkDir [file dirname $WorkDir]

source "$WorkDir/config.tcl"
source "$WorkDir/params.tcl"

set Myext ls

switch [llength $args] {
1 {
	set lfs [open "$Myhome/[lindex $args 0].$Myext" r]
	set pager [open [concat "|" [param_or_val p $::env(PAGER)]] w]
	while {[gets $lfs ln] > 0} {
		if [regexp {^(\d+)\t(.+)$} $ln all date mesg] {
			puts $pager "[clock format $date -format $Mytime]\t$mesg"
		}
	}
	close $lfs
	close $pager}
0 { puts {Put line in list 
	<list> <mesgpart0> [-t=<utime>] <part1> .. <partn>
Print list 
	<list> [-p=<pager, def PAGER>]}}
default {
	puts [open "$Myhome/[lindex $args 0].$Myext" a] "[param_or_val t [clock seconds]]\t[lrange $args 1 end]"
}}

