#!/bin/sh
if [ -z $1 ] 
then
	echo "#######################################################################################"
	echo
	echo "		 This is how to use this file          "
	echo "[root@test65 ~]# make_tdf28nm.sh [vclef file] [.v file] [x_size] [y_size] [core_offset]"
	echo "#######################################################################################"
	echo 
 	exit 1
else if [ -z $2 ] 
then
	echo "#######################################################################################"
	echo
	echo "		 This is how to use this file          "
	echo "[root@test65 ~]# make_tdf28nm.sh [vclef file] [.v file] [x_size] [y_size] [core_offset]"
	echo "#######################################################################################"
	echo 
 	exit 1
else if [ -z $3 ] 
then
	echo "#######################################################################################"
	echo
	echo "		 This is how to use this file          "
	echo "[root@test65 ~]# make_tdf28nm.sh [vclef file] [.v file] [x_size] [y_size] [core_offset]"
	echo "#######################################################################################"
	echo 
 	exit 1
else if [ -z $4 ] 
then
	echo "#######################################################################################"
	echo
	echo "		 This is how to use this file          "
	echo "[root@test65 ~]# make_tdf28nm.sh [vclef file] [.v file] [x_size] [y_size] [core_offset]"
	echo "#######################################################################################"
	echo 
 	exit 1
else if [ -z $5 ] 
then
	echo "#######################################################################################"
	echo
	echo "		 This is how to use this file          "
	echo "[root@test65 ~]# make_tdf28nm.sh [vclef file] [.v file] [x_size] [y_size] [core_offset]"
	echo "#######################################################################################"
	echo 
 	exit 1
else
	tmp_pin=/tmp/pin.txt
	tmp_rect=/tmp/rect.txt
	tmp_rect_cmpl=/tmp/rect_cmpl.txt
	tmp_tdf=/tmp/tdf.txt
	result_file=./memory_wrapper.tdf
	
	pin_name=`grep -m 1 module $2 | cut -d'(' -f2 | cut -d ')' -f1 | tr ',' '|' | tr -d ' '`	
	
	grep PIN $1 > $tmp_pin
	grep "RECT " $1 > $tmp_rect

	prev_txt="rect first"
	cat /dev/null > $tmp_rect_cmpl
	while read line 
	do
		if [ "$prev_txt" != "$line" ];
		then
    			echo $line >> $tmp_rect_cmpl
			prev_txt="$line"
		fi
	done < $tmp_rect
	
	count2=1
	cat /dev/null > $tmp_tdf
	while read line2
	do
		offset0=`head -$count2 $tmp_rect_cmpl | tail -1 | cut -d' ' -f2`                 # 57.162
		offset1=`head -$count2 $tmp_rect_cmpl | tail -1 | cut -d' ' -f2 | cut -d'.' -f1` # 57
		offset2=`head -$count2 $tmp_rect_cmpl | tail -1 | cut -d' ' -f2 | cut -d'.' -f2` # 162

		let offset1=$offset1+$5

		# awk is floating point calculation :: should use with echo "$1 $2 $3 $4" | awk '{printf,  $1 - $2 - $3 - $4}'
		# User do !!! modify your self below 0.5
		echo "set_individual_pin_constraints -ports {`echo $line2 | cut -d' ' -f2`} -allowed_layers {M2} -side 1 -width 0.1 -length 0.1 -offset `echo "$4 $5 $offset0 0.5" | awk '{printf "%.1f", $1-$2-$3-$4}'` " >> $tmp_tdf
		count2=`expr $count2 + 1`
	done < $tmp_pin
	grep -E -w "$pin_name" $tmp_tdf > $result_file
	rm -f $tmp_pin
	rm -f $tmp_rect
	rm -f $tmp_rect_cmpl
	rm -f $tmp_tdf
fi
fi
fi
fi
fi
