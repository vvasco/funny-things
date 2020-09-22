#!/bin/bash
#######################################################################################
# Copyright: (C) 2017
# Author:  Valentina Vasco
# email:   valentina.vasco@iit.it
# Permission is granted to copy, distribute, and/or modify this program
# under the terms of the GNU General Public License, version 2 or any
# later version published by the Free Software Foundation.
#  *
# A copy of the license can be found at
# http://www.robotcub.org/icub/license/gpl.txt
#  *
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details
#######################################################################################


#######################################################################################
# HELP
#######################################################################################
usage() {
cat << EOF
***************************************************************************************
INCIPIT SCRIPTING
Author:  Valentina Vasco    <valentina.vasco@iit.it>

This script scripts through the commands available for the event Danieli at Udine .

USAGE:
        $0 options

***************************************************************************************
OPTIONS:

***************************************************************************************
EXAMPLE USAGE:

***************************************************************************************
EOF
}

#######################################################################################
# HELPER FUNCTIONS
#######################################################################################
gaze() {
    echo "$1" | yarp write ... /gaze
}

speak() {
    echo "\"$1\"" | yarp write ... /iSpeak
}

blink() {
    echo "blink" | yarp rpc /iCubBlinker/rpc
    sleep 0.5
}

breathers() {
    # echo "$1"  | yarp rpc /iCubBlinker/rpc
    # echo "$1" | yarp rpc /iCubBreatherH/rpc:i
    echo "$1" | yarp rpc /iCubBreatherRA/rpc:i
    sleep 0.4
    echo "$1" | yarp rpc /iCubBreatherLA/rpc:i
}

breathersL() {
   echo "$1" | yarp rpc /iCubBreatherLA/rpc:i
}

breathersR() {
   echo "$1" | yarp rpc /iCubBreatherRA/rpc:i
}

stop_breathers() {
    breathers "stop"
}

start_breathers() {
    breathers "start"
}

hold_book_both() {
    echo "ctpq time 3.0 off 0 pos (-55.7 12.8 -5.8 85.5 -50.4 0.0 14.0 15.0 15.1 30.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 3.0 off 0 pos (-55.7 12.8 -5.8 85.5 -50.4 0.0 14.0 50.0 70.0 30.0 1.0 1.0 1.0 1.0 1.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
}

take_book_left() {
    echo "ctpq time 3.0 off 0 pos (-80.8 29.8 21.1 18.2 0.0 0.0 0.2 15.0 15.14 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
}

take_book_right() {
    echo "ctpq time 3.0 off 0 pos (-80.8 29.8 21.1 18.2 0.0 0.0 0.2 50.0 70.0 20.0 1.0 1.0 1.0 1.0 1.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
}

grasp_book_left() {
    echo "ctpq time 3.0 off 7 pos (3.23 35.94 46.8 81.6 54.0 112.4 60.3 83.2 100.0)" | yarp rpc /ctpservice/left_arm/rpc
}

grasp_book_right() {
    echo "ctpq time 3.0 off 7 pos (50.0 70.0 36.8 71.6 44.0 112.4 33.3 76.2 100.0)" | yarp rpc /ctpservice/right_arm/rpc
}

open_hand_left() {
    echo "ctpq time 3.0 off 7 pos (15.0 15.14 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
}

open_hand_right() {
    echo "ctpq time 3.0 off 7 pos (50.0 70.0 20.0 1.0 1.0 1.0 1.0 1.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
}

go_home_helperL() {
    # This is with the arms over the table
    echo "ctpq time $1 off 0 pos (-12.0 24.0 23.0 64.0 -7.0 -5.0 10.0    12.0 -6.0 37.0 2.0 0.0 3.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/left_arm/rpc
    # This is with the arms close to the legs
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
}

go_home_helperR() {
    # This is with the arms over the table
    echo "ctpq time $1 off 0 pos (-15.0 23.0 22.0 48.0 13.0 -10.0 8.0    0.0 9.0 42.0 2.0 0.0 1.0 0.0 8.0 4.0)" | yarp rpc /ctpservice/right_arm/rpc
    # This is with the arms close to the legs
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
}

go_home_helper() {
    go_home_helperR $1
    go_home_helperL $1
}

go_home() {
    #breathers "stop"
    sleep 1.0
    go_home_helper 2.0
    sleep 3.0
    #breathers "start"
}

smile() {
    echo "set all hap" | yarp rpc /icub/face/emotions/in
}

surprised() {
    #echo "set mou sur" | yarp rpc /icub/face/emotions/in
    echo "set leb sur" | yarp rpc /icub/face/emotions/in
    echo "set reb sur" | yarp rpc /icub/face/emotions/in
}

sad() {
    echo "set mou sad" | yarp rpc /icub/face/emotions/in
    echo "set leb sad" | yarp rpc /icub/face/emotions/in
    echo "set reb sad" | yarp rpc /icub/face/emotions/in
}

cun() {
    echo "set reb cun" | yarp rpc /icub/face/emotions/in
    echo "set leb cun" | yarp rpc /icub/face/emotions/in
}

angry() {
    echo "set all ang" | yarp rpc /icub/face/emotions/in
}

evil() {
    echo "set all evi" | yarp rpc /icub/face/emotions/in
}

wait_till_quiet() {
    sleep 0.3
    isSpeaking=$(echo "stat" | yarp rpc /iSpeak/rpc)
    while [ "$isSpeaking" == "Response: speaking" ]; do
        isSpeaking=$(echo "stat" | yarp rpc /iSpeak/rpc)
        sleep 0.1
        # echo $isSpeaking
    done
    echo "I'm not speaking any more :)"
    echo $isSpeaking
}

#######################################################################################
# SEQUENCE FUNCTIONS
#######################################################################################
sequence() {
    smile
    #take_book_right
    #sleep 3.0
    #grasp_book_right
    speak "Nel mezzo del ca mmin di nostra vita, mi ritrovai per una selva oscura, ché la diritta via era smarrita"
    wait_till_quiet
    sleep 3.0
    
    speak "Cer to. Mi preparo l'incipit per la leczio del 15 ottobre!"
    wait_till_quiet
    sleep 3.0
    
    speak "Quindi venite a trovare anche me all’IIT?"
    wait_till_quiet
    sleep 3.0

    speak "Vi aspetto qui allora!"
    wait_till_quiet
    speak "Alla giusta distanza"
}

#######################################################################################
# "MAIN" FUNCTION:                                                                    #
#######################################################################################
echo "********************************************************************************"
echo ""

$1 "$2"

if [[ $# -eq 0 ]] ; then
    echo "No options were passed!"
    echo ""
    usage
    exit 1
fi
