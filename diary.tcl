#!/usr/bin/tclsh

# arg pair is -t -time -trap=no, but no -trap yes
proc args_parse {arguments} {
	variable pairs 
	variable other

	foreach p $arguments {
		if [regexp -- {-(\w+)(?:=(\w+))?} $p all pname pval] {
			lappend pairs [list $pname $pval]
		} else { lappend other $p}
	}
	return [list $pairs $other]
}
proc myhome {mypath} {
	global Myhome
	return [append $Myhome "/" mypath]
}
proc file_name {path} {
	set sep_path [file split $path]
	return [lindex $sep_path [expr [llength $sep_path] - 1]]
}
proc file_list {type {use_files 0}} {
	global files
	return [lsearch -all -inline -regexp type [expr $use_files? $use_files: $files]]
}

#set args [list leppo "-t" "-alarm=5am" i vant be with you yestoday]
#puts [args_parse $args]


set Myhome "/tmp"
set files [lsort [glob -directory $Myhome *]]

set arguments [args_parse $argv]
set params [lindex $arguments 0]
set mode [lindex $arguments 1]
set data [lrange $arguments 2 end]

puts [list $arguments $params $mode $data]

switch $mode {
	more {puts [append $::env(EDITOR) " " [myhome [clock seconds]]]}
	safe {puts [append "cp -r " [lindex $data 0] " " [myhome [file_path [lindex $data 0]]]]}
	default { puts "mayby help" }
}
