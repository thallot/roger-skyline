#!/bin/bash
SAUV_TAB=sauv_crontab.txt
TAB=crontab.txt
if [ ! -f "$SAUV_TAB" ]
then
	md5sum /etc/crontab > "$SAUV_TAB"
	sudo sendmail tom.2306@hotmail.fr < /home/toto/script/mail
else
	md5sum /etc/crontab > "$TAB"
	DIFF=$(diff "$TAB" "$SAUV_TAB")
	if [  "$DIFF" ]
	then
		sudo sendmail tom.2306@hotmail.fr < /home/toto/script/mail
	fi
	rm "$TAB"
fi
