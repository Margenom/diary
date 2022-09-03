set params [list]; set args [list]
# arg pair is -t -time -trap=no, but no -trap yes
foreach p $argv { if [regexp -- {^-([^=]+)(?:=(.+))?$} $p all pname pval] { 
	lappend params [list $pname $pval] 
} else { lappend args $p} }

# param or value
proc param_or_val {name orval {convert 0}} {
	global params
	set val [lsearch -index 0 -inline $params $name]
	if [string eq $val ""] { return $orval } else { set val [lindex $val 1]
		if [string eq $convert 0] { return $val} else { return [$convert $val]}
	} 
}
