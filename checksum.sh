#!/bin/bash

FILEDB="/root/scripts/checksum/file.db"
SUMFILE="/root/scripts/checksum/sumfile.db"
OPTION="null"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

function check {  #update the table and output to user

for i in `cat $FILEDB` ; do

	FILE=$i
        NEWSUM=`md5sum $FILE | awk '{print $1}'`
        OLDSUM=`grep -w $FILE $SUMFILE | awk '{print $3}'`

#checks if the file is in the db. adds to sumfile.new if not. writes current sum and status to table
        if grep $FILE $SUMFILE > /dev/null
        then
        	echo -e "$FILE is registered in database, comparing to previous md5sum..."

#if the file is already in the db, compares the current checksum to the old value and sets the STATUS accordingly.
                if [ $NEWSUM = $OLDSUM ]
                then
                	STATUS=`echo -e "${GREEN}OK${NC}"`
                else
                	STATUS=`echo -e "${RED}CHANGED${NC}"`
                fi

                echo -e "$FILE\t$STATUS\t$NEWSUM" >> sumfile.new
	else
        	echo -e "$FILE added to Database\n"
                echo -e "$FILE\t${GREEN}OK${NC}\t$NEWSUM" >> sumfile.new
	fi
done

rm -f $SUMFILE
mv sumfile.new $SUMFILE
echo ; cat $SUMFILE ; echo

read -p "Press any key to return to main Menu: "

}

rm -f sumfile.new 2> /dev/null

while [ $OPTION != "4" ] ; do
	
	echo -e "\nSumCheck\n--------\n1. Run Integrity Check\n2. Add File To Registry\n3. Remove File From Registry\n4. Exit\n"
	read -p "Choose an option to Continue: " OPTION ; echo 

#OPTION 1 - update the table and output it to the user
	if [ $OPTION = "1" ] ; then
		check

#OPTION 2 - adds a new file to the db, updates it and outputs the table to the user
	elif [ $OPTION = "2" ] ; then
		read -p "Enter full path of file to be Added: " NEWFILE ; echo

#checks if the added file really exists		
		if test -f $NEWFILE ; then
			echo -e "$NEWFILE" >> file.db
			check
		else
			echo -e "${RED}Invalid Path${NC}\n"
		fi

#OPTION 3 - removes a file from the db
	elif [ $OPTION = "3" ] ; then
		read -p "Enter full path of file to be Removed: " REMOVE ; echo

#checks if the inputed file to be removed exists in the db
		if test -f "$REMOVE" && grep -w "$REMOVE" "$FILEDB" ; then
			grep -v $REMOVE $FILEDB > file.db.new
			echo -e "$REMOVE removed from Database\n"
			rm -f $FILEDB
		        mv file.db.new $FILEDB
			check
		else
			echo -e "${RED}Invalid Path${NC}\n"
		fi

#OPTION 4 - exit
	elif [ $OPTION = "4" ] ; then
		echo -e "Exiting...\n"

#INVALID OPTION
	else 
		echo -e "${RED}Invalid Option${NC}\n"
	fi
done

clear




