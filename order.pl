#!/usr/bin/perl

$ORDER_LIST="order.log";

###records always
#DATATIME (in unix time)\tLENGTH (in seconds)\tCAT\tMORE...\tMESSGE (last in string using only spases as determine words 


# STAT fo (List: (DATE, LENG, CAT, ETC..., MESG))
sub order_rec (@rec) {
	open($fp, '>>', $ORDER_LIST) or return 1;

	print $fp join ('\t', @rec);
	close $fp;
	0;
}

# LIST fo (COUNT)
sub order_read_last ($count) {
	open($fp, '<' $ORDER_LIST) or return 0;

	$last = "";
	while (<$fp>) $last = $_;

	close $fp;
	return split (/\t/, $last);
}

sub order_time_now { time() };
sub order_time_hum { localtime(shift) };

# STAT fo (CAT, ETC..., MESG)
sub order_app {
	$time = order_time_now();
	@last = order_read_last();
	$leng = $time - $last[0];

	unshift @_, $time, $leng;
	return order_rec(@_);
}

sub order_pretty_print (@rec) {
	$rec[0] = order_time_now($rec[0]);
	$rec[1] = ($rec[1]/60) . " min";

	print join( "\t", @rec);
	0;
}

###commands 
#temp -c<cat> -b<beg> -l<len> <...mesg>	- add record

sub parser(@sur) {
	%atom;
	@mes;

	map {($_ =~ m/-([a-z])(.*)/)? $atom{$1 or "-"} = $2 or "-" : push @mes $_} @replist;
	$atom{mesg} = \@mes;
	%atom;
}

%a = parser @ARGV; 

$a{c} = $a{c} or "";
$a{b} = $a{b} or (order_read_last())[0];
$a{l} = $a{l} or ($a{b}
