set Myhome $::env(MYCLOSEDIR)
if [string eq "" $Myhome] { set Myhome $::env(HOME)}
set Mytime "%a %d.%m (%Y) %H:%M"
