
 #!/bin/bash

#######################################################################################
# HELP
#######################################################################################
usage() {
cat << EOF

***************************************************************************************
TOBIA VIDEO SCRIPTING
Authors:
- Valentina Vasco   <valentina.vasco@iit.it>
- Ettore Landini    <ettore.landini@iit.it>

This script scripts through the commands available for the shooting of Tobia movie

USAGE:
        $0 options
  
        
***************************************************************************************
EOF
}

#######################################################################################
# GLOBAL VARIABLES
#######################################################################################
DRAW_TIME=1.5

#######################################################################################
# HELPER FUNCTIONS
#######################################################################################
start_breathers() {
    echo "start" | yarp rpc /iCubBreatherHead/rpc:i
    echo "start" | yarp rpc /iCubBreatherLeft/rpc:i
    echo "start" | yarp rpc /iCubBreatherRight/rpc:i
}

stop_breathers() {
    echo "stop" | yarp rpc /iCubBreatherHead/rpc:i
    echo "stop" | yarp rpc /iCubBreatherLeft/rpc:i
    echo "stop" | yarp rpc /iCubBreatherRight/rpc:i
}

speak() {
    echo "\"$1\"" | yarp write ... /iSpeak
}

move_eyelids() {
    echo "$1" | yarp write ... /icub/face/raw/in
}

close_eyes() {
    move_eyelids "S40"
}

open_eyes() {
    move_eyelids "S60"
}

squint() {
    move_eyelids "S45"
}

open_eyes_sequentially() {
    for i in {40..60}
    do
        APERTURE="S$i"
        echo $APERTURE
        move_eyelids $APERTURE
        sleep 1.0   
    done
}

roll_neck() {
    fix_point 3.0 0.0 15.0 0.0 0.0 0.0 0.0
    fix_point 3.0 0.0 -15.0 0.0 0.0 0.0 0.0
}

pitch_neck() {
    fix_point 3.0 18.0 0.0 0.0 0.0 0.0 0.0
    fix_point 3.0 -30.0 0.0 0.0 0.0 0.0 0.0
}

yaw_neck() {
    fix_point 3.0 0.0 0.0 40.0 0.0 0.0 0.0
    fix_point 3.0 0.0 0.0 -40.0 0.0 0.0 0.0
}

tilt_eyes() {
    fix_point 3.0 0.0 0.0 0.0 25.0 0.0 0.0
    fix_point 3.0 0.0 0.0 0.0 -25.0 0.0 0.0
}

version_eyes() {
    fix_point 3.0 0.0 0.0 0.0 0.0 25.0 0.0
    fix_point 3.0 0.0 0.0 0.0 0.0 -25.0 0.0
}

verge_eyes() {
    fix_point 3.0 0.0 0.0 0.0 0.0 0.0 0.0
    fix_point 3.0 0.0 0.0 0.0 0.0 0.0 40.0
}

point() {
    echo "ctpq time $1 off 0 pos (-91.0 36.0 13.0 46.0 -21.5 -5.5 -6.0 18.0 21.5 25.0 69.5 8.0 22.0 65.5 129.0 172.5)" | yarp rpc /ctpservice/$2/rpc
}

point_glass() {
    echo "ctpq time $1 off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 10.0 18.0 21.5 25.0 69.5 8.0 22.0 65.5 129.0 172.5)" | yarp rpc /ctpservice/$2/rpc
}

point_breast() {
    echo "ctpq time $1 off 0 pos (-31.5 43.5 49.5 103.0 -42.0 22.0 -14.5 0.0 10.0 20.0 95.0 3.0 27.0 3.0 27.0 17.5)" | yarp rpc /ctpservice/$2/rpc
}

point_forehead() {
    echo "ctpq time $1 off 0 pos (-65.5 40.0 12.5 105.0 -31.5 24.0 -8.0 18.0 21.5 25.0 69.5 8.0 30.0 65.5 129.0 172.5)" | yarp rpc /ctpservice/$2/rpc
}

point_face() {
    echo "ctpq time $1 off 0 pos (-43.2 24.0 10.5 105.0 -46.0 24.0 -6.7 18.0 21.5 25.0 69.5 8.0 54.4 65.5 129.0 172.5)" | yarp rpc /ctpservice/$2/rpc
}

point_straight() {
    echo "ctpq time $1 off 0 pos ($2 $3 3.5 20.0 $4 28.0 -6.0 57.0 55.0 30.0 33.0 4.0 9.0 58.0 113.0 192.0)" | yarp rpc /ctpservice/$5/rpc
}

nod() {
    START=$1
    TIME=$2
    TUNCOVER=$(bc <<< "$START - 8")
    echo "ctpq time $TIME off 0 pos ($END)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TIME off 0 pos ($START)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TIME off 0 pos ($END)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TIME off 0 pos ($START)" | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TIME off 0 pos ($END)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TIME off 0 pos ($START)" | yarp rpc /ctpservice/head/rpc
}

clean() {
    RANGE=15
    TIME=0.3
    echo "ctpq time $TIME off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 $RANGE 28.0 10.0 6.0 10.0 0.0 0.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 -$RANGE 28.0 10.0 6.0 10.0 0.0 0.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 $RANGE 28.0 10.0 6.0 10.0 0.0 0.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 -$RANGE 28.0 10.0 6.0 10.0 0.0 0.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 $RANGE 28.0 10.0 6.0 10.0 0.0 0.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 -$RANGE 28.0 10.0 6.0 10.0 0.0 0.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 $RANGE 28.0 10.0 6.0 10.0 0.0 0.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 -$RANGE 28.0 10.0 6.0 10.0 0.0 0.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 $RANGE 28.0 10.0 6.0 10.0 0.0 0.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 -$RANGE 28.0 10.0 6.0 10.0 0.0 0.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 0 pos (-50.0 22.0 33.0 50.0 40.0 15.5 0.0 28.0 10.0 6.0 10.0 0.0 0.0 2.0 1.0 0.0)" | yarp rpc /ctpservice/$1/rpc
}

look_down() {
    echo "ctpq time 1.0 off 0 pos (-27.5 0.0 0.0 -20.5 0.0 5.0)"  | yarp rpc /ctpservice/head/rpc
}

gaze() {
    echo "$1" | yarp write ... /gaze
}

generic_gaze() {
    gaze "set-delta 30 10 1" 
    gaze "look-around 0.0 0.0 5.0"
}

fix_only_eyes_left() {
    echo "ctpq time 1.0 off 3 pos (0.0 -20.0 5.0)"  | yarp rpc /ctpservice/head/rpc
}

fix_only_eyes_right() {
    echo "ctpq time 1.0 off 3 pos (0.0 20.0 5)"  | yarp rpc /ctpservice/head/rpc
}

fix_only_eyes_down() {
    echo "ctpq time 1.0 off 3 pos (-20.0 0.0 5)"  | yarp rpc /ctpservice/head/rpc
}

fix_only_eyes_up() {
    echo "ctpq time 1.0 off 3 pos (20.0 0.0 5)"  | yarp rpc /ctpservice/head/rpc
}

fix_only_eyes() {
    AZI=$(bc <<< "20*$1")
    echo "ctpq time 1.0 off 3 pos ($AZI 0.0 5)"  | yarp rpc /ctpservice/head/rpc
}

follow_only_eyes() {
    AZI=$(bc <<< "20*$1")
    gaze_only_eyes "look $AZI 0.0 5.0"
}

look_around_eyes() {
    echo "ctpq time $1 off 3 pos (0.0 0.0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 3 pos (1.0 3.0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 3 pos (5.0 -5.0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 3 pos (-10.0 0.0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 3 pos (-6.0 2.0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 3 pos (4.0 8.0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 3 pos (0.0 -1.0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $1 off 3 pos (-3.0 6.0)"  | yarp rpc /ctpservice/head/rpc
}

follow_draw_wall_left() {
    ENDEYE=$(bc <<< "$1 - $2")
    fix_point $DRAW_TIME 0.0274725 0.021978 31 0.043956 $1 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 31 0.043956 $ENDEYE 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 31 0.043956 $1 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 31 0.043956 $ENDEYE 2.00394
    fix_point $DRAW_TIME 0.0274725 0.021978 31 0.043956 $1 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 31 0.043956 $ENDEYE 2.00394
    fix_point $DRAW_TIME 0.0274725 0.021978 31 0.043956 $1 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 31 0.043956 $ENDEYE 2.00394
}

follow_draw_wall_right() {
    ENDEYE=$(bc <<< "$1 - $2")
    fix_point $DRAW_TIME 0.0274725 0.021978 -31 0.043956 $1 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 -31 0.043956 $ENDEYE 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 -31 0.043956 $1 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 -31 0.043956 $ENDEYE 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 -31 0.043956 $1 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 -31 0.043956 $ENDEYE 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 -31 0.043956 $1 2.00394	
    fix_point $DRAW_TIME 0.0274725 0.021978 -31 0.043956 $ENDEYE 2.00394
}

follow_draw_line_left() {
    ENDEYE=$(bc <<< "$1 - $2") #WE NEED THE EXTRASPACE BEFORE AND AFTER THE MINUS
    echo $ENDEYE
    fix_point $DRAW_TIME 0.0274725 0.021978 18.0 0.043956 $1 10.0	
    fix_point $DRAW_TIME 0.0274725 0.021978 18.0 0.043956 $ENDEYE 10.0	
}

follow_draw_line_right() {
    ENDEYE=$(bc <<< "$1 - $2") #WE NEED THE EXTRASPACE BEFORE AND AFTER THE MINUS
    echo $1 $2 $ENDEYE
    fix_point $DRAW_TIME 0.0274725 0.021978 -18.0 0.043956 $1 10.0	
    fix_point $DRAW_TIME 0.0274725 0.021978 -18.0 0.043956 $ENDEYE 10.0	
}

choreography() {
    TEMPO=${1:-0.834}
    ARM=${2:-"left_arm"}
    OBSERVE=${3:-1.5}
    case "$ARM" in
    "left_arm") YAWTOARM=15 ;;
    *) YAWTOARM=-15 ;;
    esac
    TOWAIT=$(bc <<< "$OBSERVE * 3")

    # ARM settings
    SHLDSPEED=20
    ELBSPEED=26
    SHLDRANGE=$(bc <<< "$SHLDSPEED * $TEMPO")
    SHLDMIDDLE=-10.0
    SHLDSTART=$(bc <<< "$SHLDMIDDLE - $SHLDRANGE")
    SHLDEND=$(bc <<< "$SHLDMIDDLE + $SHLDRANGE")
    ELBRANGE=$(bc <<< "$ELBSPEED * $TEMPO")
    ELBMIDDLE=50.0
    ELBEND=$(bc <<< "$ELBMIDDLE + $ELBRANGE")

    #Head settings
    YAWSPEED=20
    PITCHSPEED=20
    YAWRANGE=$(bc <<< "$YAWSPEED * $TEMPO")
    YAWMIDDLE=0
    YAW1=$(bc <<< "$YAWMIDDLE - $YAWRANGE")
    YAW2=$(bc <<< "$YAWMIDDLE + $YAWRANGE")
    case "$ARM" in
    "left_arm") YAWSTART=$YAW1 ;;
    *) YAWSTART=$YAW2 ;;
    esac
    case "$ARM" in
    "left_arm") YAWEND=$YAW2 ;;
    *) YAWEND=$YAW1 ;;
    esac
    PITCHRANGE=$(bc <<< "$PITCHSPEED * $TEMPO")
    PITCHMIDDLE=-5.0
    PITCHEND=$(bc <<< "$PITCHMIDDLE + $PITCHRANGE")

    #Torso settings
    TYAWSPEED=15
    TYAWRANGE=$(bc <<< "$TYAWSPEED * $TEMPO")
    TYAWMIDDLE=0
    TYAW1=$(bc <<< "$TYAWMIDDLE - $TYAWRANGE")
    TYAW2=$(bc <<< "$TYAWMIDDLE + $TYAWRANGE")
    case "$ARM" in
    "left_arm") TYAWSTART=$TYAW1 ;;
    *) TYAWSTART=$TYAW2 ;;
    esac
    case "$ARM" in
    "left_arm") TYAWEND=$TYAW2 ;;
    *) TYAWEND=$TYAW1 ;;
    esac

    echo "ctpq time $OBSERVE off 0 pos (10 0 0 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $OBSERVE off 0 pos (0 0 -10 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $OBSERVE off 0 pos (-10 0 $YAWTOARM 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    sleep $TOWAIT

    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDSTART $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDEND $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    sleep $TEMPO

    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDSTART $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDEND $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos (0 0 0 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    sleep $TEMPO

    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDSTART $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHEND 0 $YAWSTART 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHMIDDLE 0 $YAWMIDDLE 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDEND $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHEND 0 $YAWEND 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHMIDDLE 0 $YAWMIDDLE 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    sleep $TEMPO

    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDSTART $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHEND 0 $YAWSTART 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWSTART 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHMIDDLE 0 $YAWMIDDLE 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWMIDDLE 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDEND $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHEND 0 $YAWEND 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWEND 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHMIDDLE 0 $YAWMIDDLE 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWMIDDLE 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO

    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDSTART $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHEND 0 $YAWSTART 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWSTART 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHMIDDLE 0 $YAWMIDDLE 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWMIDDLE 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDEND $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHEND 0 $YAWEND 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWEND 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHMIDDLE 0 $YAWMIDDLE 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWMIDDLE 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO

    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDSTART $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHEND 0 $YAWSTART 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWSTART 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHMIDDLE 0 $YAWMIDDLE 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWMIDDLE 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDEND $ELBEND 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHEND 0 $YAWEND 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWEND 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO
    echo "ctpq time $TEMPO off 0 pos (-25 20 $SHLDMIDDLE $ELBMIDDLE 0 0 0 18 21.5 25 69.5 8 22 65.5 129 172.5)" | yarp rpc /ctpservice/$ARM/rpc
    echo "ctpq time $TEMPO off 0 pos ($PITCHMIDDLE 0 $YAWMIDDLE 0 0 0)"  | yarp rpc /ctpservice/head/rpc
    echo "ctpq time $TEMPO off 0 pos ($TYAWMIDDLE 0 0)"  | yarp rpc /ctpservice/torso/rpc
    sleep $TEMPO
}

set_speed_eyes() {
    echo "set Teyes $1" | yarp rpc /iKinGazeCtrl/rpc
}

set_speed_neck() {
    echo "set Tneck $1" | yarp rpc /iKinGazeCtrl/rpc
}

take_pen_wall_right() {
    START=${1:-30}
    echo "ctpq time 3.0 off 0 pos (-80.1648 $START -5.31495 52.7582 0.000353772 -0.043956 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc  
}

take_pen_wall_left() {
    START=${1:-30}
    echo "ctpq time 3.0 off 0 pos (-80.1648 $START -5.31495 52.7582 0.000353772 -0.043956 -0.142857 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc  
}

greet() {
    echo "ctpq time 1.5 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -10.0 0.0 20.0 11.0 1.0 11.0 3.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/$2/rpc
    echo "ctpq time $1 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -10.0 10.0)" | yarp rpc /ctpservice/$2/rpc
    echo "ctpq time $1 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -10.0 -10.0)" | yarp rpc /ctpservice/$2/rpc
    echo "ctpq time $1 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -10.0 10.0)" | yarp rpc /ctpservice/$2/rpc
    echo "ctpq time $1 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -10.0 -10.0)" | yarp rpc /ctpservice/$2/rpc
    echo "ctpq time $1 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -10.0 10.0)" | yarp rpc /ctpservice/$2/rpc
    echo "ctpq time $1 off 0 pos (-70.0 40.0 -7.0 100.0 60.0 -10.0 -10.0)" | yarp rpc /ctpservice/$2/rpc
}

cover_left_eye() {
    echo "ctpq time $1 off 0 pos (-67.19 19 25.74 95 -60 0 0 15.0 20.0 20.0 17.0 10.0 13.5 10.0 13.0 5.0)" | yarp rpc /ctpservice/left_arm/rpc
}

cover_right_eye() {
    echo "ctpq time $1 off 0 pos (-67.19 19 25.74 95 -60 0 0 57.0 20.0 0.0 0.0 0.0 0.0 0.0 0.0 2.5)" | yarp rpc /ctpservice/right_arm/rpc
}

uncover_left_eye() {
    echo "ctpq time $1 off 0 pos (-35 35 16 95 -60 0 0 15.0 20.0 20.0 17.0 10.0 13.5 10.0 13.0 5.0)" | yarp rpc /ctpservice/left_arm/rpc
}

uncover_right_eye() {
    echo "ctpq time $1 off 0 pos (-35 35 16 95 -60 0 0 57.0 20.0 0.0 0.0 0.0 0.0 0.0 0.0 2.5)" | yarp rpc /ctpservice/right_arm/rpc
}

peek_a_boo(){
    TARM=$1
    TOPEN=$2
    THIDE=$3
    gaze "idle"
    cover_left_eye $TARM
    sleep $TARM
    #happy
    cover_right_eye $TARM
    sleep $TARM
    close_eyes
    sleep $THIDE
    TUNCOVER=$(bc <<< "$TOPEN*2")
    echo $TUNCOVER
    uncover_left_eye $TUNCOVER
    uncover_right_eye $TUNCOVER
    sleep $TOPEN
    open_eyes
    #surprised
}

emotion() {
    MOU=${1:-neu}
    LEB=${2:-$1}
    REB=${3:-$LEB}
    echo "set mou $MOU" | yarp rpc /icub/face/emotions/in
    echo "set leb $LEB" | yarp rpc /icub/face/emotions/in
    echo "set reb $REB" | yarp rpc /icub/face/emotions/in
}

happy() {
    emotion "hap"
}

neutral() {
    emotion "neu"
}

sad() {
    emotion "sad"
}

surprised() {
    emotion "hap" "sur"
}

curious() {
    emotion "neu" "shy"
}

arm_sleeve_left() {
    echo "ctpq time $1 off 0 pos (-48.48 25.71 3.5 29.99 39.6 6.37 -2.65 59.65 69.97 70.87 19.98 10.4 10.02 10.37 9.07 5.3)" | yarp rpc /ctpservice/left_arm/rpc
}

arm_sleeve_right() {
    echo "ctpq time $1 off 0 pos (-48.48 25.71 3.5 29.99 39.6 6.37 -2.65 59.65 33.6 70.0 1.7 0.0 1.7 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc
}

fix_point(){
    echo "ctpq time $1 off 0 pos ($2 $3 $4 $5 $6 $7)"  | yarp rpc /ctpservice/head/rpc
}

caress() {
    RANGE=13.5
    TIME=1.5
    echo "ctpq time 1.5 off 0 pos (-78.0 33.7 -4.0 46.5 21.6 15.7 $RANGE 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$1/rpc
    sleep 2.0
    echo "ctpq time $TIME off 6 pos (-$RANGE 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 6 pos ($RANGE 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 6 pos (-$RANGE 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 6 pos ($RANGE 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$1/rpc
    echo "ctpq time $TIME off 6 pos (-$RANGE 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$1/rpc
}

caress_elbow() {
    START=46.5
    PLUS=63.0
    MINUS=30.0
    MINUSW=15.0
    PLUSW=-15.0
    TIME=$1
    echo "ctpq time 2.0 off 0 pos (-78.0 33.7 -4.0 $START 21.6 15.7 0 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$2/rpc
    sleep 2.0
    echo "ctpq time $TIME off 3 pos ($PLUS 21.6 15.7 $MINUSW 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$2/rpc
    echo "ctpq time $TIME off 3 pos ($MINUS 21.6 15.7 $PLUSW 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$2/rpc
    echo "ctpq time $TIME off 3 pos ($PLUS 21.6 15.7 $MINUSW 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$2/rpc
    echo "ctpq time $TIME off 3 pos ($MINUS 21.6 15.7 $PLUSW 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$2/rpc
    echo "ctpq time $TIME off 3 pos ($PLUS 21.6 15.7 $MINUSW 20.0 10.0 16.2 34.0 2.7 30.5 0.0 30.5 10.0)" | yarp rpc /ctpservice/$2/rpc
}

draw_table_right() {
    echo "ctpq time 2.0 off 0 pos (-84.35 67.65 56.69 58.38 1.23 -2.33 13.44 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2.0 off 0 pos (-84.35 77.23 56.6 58.38 1.23 -2.33 13.44 16.75 20.71 23.91 29.79 36 52.52 42.96 49.4 95.54)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2.0 off 0 pos (-84.35 62.81 56.78 58.38 1.23 -2.24 13.53 15.85 21.49 22.17 30.52 36.4 50.11 42.22 40.3 93.94)" | yarp rpc /ctpservice/right_arm/rpc
}

draw_table_left() {
    echo "ctpq time 2.0 off 0 pos (-84.35 67.65 56.69 58.38 1.23 -2.33 13.44 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 2.0 off 0 pos (-84.35 77.23 56.6 58.38 1.23 -2.33 13.44 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 2.0 off 0 pos (-84.35 62.81 56.78 58.38 1.23 -2.24 13.53 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc
}

draw_point_right() {
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 10.0 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc    
}

draw_line_right() {
    ENDARM=$(bc <<< "$1+$2")
    echo $ENDARM
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 10 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
}

draw_wall_wrist_right() {
    ENDARM=$(bc <<< "$1+$2")
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 10 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -10 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.0549451 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -10 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.0549451 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -10 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.0549451 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
}

draw_wall_no_wrist_right() {
    ENDARM=$(bc <<< "$1+$2")
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 0 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.0549451 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 0 -0.142857 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.0549451 16.75 20.84 23.48 29.79 36 49.71 42.96 40.3 95.01)" | yarp rpc /ctpservice/right_arm/rpc
}

draw_point_left() {
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 10.0 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc
}

draw_line_left() {
    ENDARM=$(bc <<< "$1+$2")
    echo $ENDARM
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 10 -0.142857 8.68525 21.4805 30 70.5475 36.7637 60.0628 68.6921 29.1707 86.5875)" | yarp rpc /ctpservice/left_arm/rpc
}

draw_wall_wrist_left() {
    ENDARM=$(bc <<< "$1+$2")
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 10 -0.142857 8.68525 21.4805 30 70.5475 36.7637 60.0628 68.6921 29.1707 86.5875)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -10 -0.142857 8.68525 21.368 30 70.9092 36.3807 61.2324 69.7943 29 86.5875)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.0549451 8.28121 22.268 30 70.9092 35.9978 57.7237 68.3248 28.1038 84.9615)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 10 -0.142857 8.68525 21.4805 30 70.5475 36.7637 60.0628 68.6921 29.1707 86.5875)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -10 -0.142857 8.68525 21.368 30 70.9092 36.3807 61.2324 69.7943 29 86.5875)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.0549451 8.28121 22.268 30 70.9092 35.9978 57.7237 68.3248 28.1038 84.9615)" | yarp rpc /ctpservice/left_arm/rpc
}

draw_wall_no_wrist_left() {
    ENDARM=$(bc <<< "$1+$2")
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.142857 8.68525 21.4805 30 70.5475 36.7637 60.0628 68.6921 29.1707 86.5875)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 0 -0.142857 8.68525 21.368 30 70.9092 36.3807 61.2324 69.7943 29 86.5875)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.0549451 8.28121 22.268 30 70.9092 35.9978 57.7237 68.3248 28.1038 84.9615)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 -0.043956 -0.142857 8 21.4805 30 71.9942 36.3807 59.2831 68.6921 28.1038 87.807)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.142857 8.68525 21.4805 30 70.5475 36.7637 60.0628 68.6921 29.1707 86.5875)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $1 -5.31495 52.7582 0.000353772 0 -0.142857 8.68525 21.368 30 70.9092 36.3807 61.2324 69.7943 29 86.5875)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $DRAW_TIME off 0 pos (-80.1648 $ENDARM -5.31495 52.7582 0.000353772 0 -0.0549451 8.28121 22.268 30 70.9092 35.9978 57.7237 68.3248 28.1038 84.9615)" | yarp rpc /ctpservice/left_arm/rpc
}

open_trex_left() {
    echo "ctpq time 3.0 off 7 pos (15.0 70.0 20.0 17.0 10.0 13.5 10.0 13.0 5.0)" | yarp rpc /ctpservice/left_arm/rpc
}

home_left_table_side() {
    echo "ctpq time 3.0 off 2 pos (15.6)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time 3.0 off 0 pos ($1 55 60.707 51.8791 -31.1995 12.5275 8.102 14.9479 70.5299 17.5509 15.213 9.95409 12.4995 9.54445 11.7454 5.28667)" | yarp rpc /ctpservice/left_arm/rpc
    fix_point 3.0 -29.4 -12.4 20.9 -10.8 0.0 5.0
    move_eyelids "S50"
}

home_left_table_top() {
    echo "ctpq time 3.0 off 2 pos (15.6)" | yarp rpc /ctpservice/torso/rpc
    echo "ctpq time 3.0 off 0 pos (-52.7 55.0 60.7949 52.85 0.0 13.0 0.032967 15.0 45.5 20.0 17.0 10.0 13.5 10.0 13.0 5.0)" | yarp rpc /ctpservice/left_arm/rpc
    fix_point 3.0 -29.4 -12.4 20.9 -10.8 0.0 5.0
    move_eyelids "S50"
}

grasp_trex_left() {
    echo "ctpq time 3.0 off 7 pos (3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
}

follow_trex_left() {
    echo "ctpq time $2 off 0 pos ($1 55 60.707 51.8791 -31.1995 12.5275 8.102 3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    fix_point $2 -29.4 -12.4 20.9 -10.8 0.0 5.0
    sleep $2

    echo "ctpq time $2 off 0 pos ($1 50 60.707 51.8791 -13.2 12.5275 8.102 3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    fix_point $2 -29.4 4.76923 18.0 -10.8 0.0 5.0
    sleep $2
    
    echo "ctpq time $2 off 0 pos ($1 50 60.707 51.8791 14.2 12.5275 8.102 3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep $2
    
    echo "ctpq time $2 off 0 pos ($1 45 60.707 51.8791 -7.0 12.5275 8.102 3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    fix_point $2 -29.4 -5.16484 16.0 -10.8 0.0 5.0
    sleep $2

    echo "ctpq time $2 off 0 pos ($1 45 60.707 51.8791 9.6 12.5275 8.102 3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep $2
    open_eyes
 
    echo "ctpq time $2 off 0 pos ($1 40 60.707 51.8791 -19.6 12.5275 8.102 3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    fix_point $2 -29.4 4.76923 15.0 -10.8 0.0 5.0
    sleep $2

    echo "ctpq time $2 off 0 pos ($1 40 60.707 51.8791 4.8 12.5275 8.102 3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep $2

    echo "ctpq time $2 off 0 pos ($1 35 60.707 51.8791 -14.8 12.5275 8.102 3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    fix_point $2 -29.4 -4.76923 11.95 -10.8 0.0 5.0
    sleep $2

    echo "ctpq time $2 off 0 pos ($1 35 60.707 51.8791 4.8 12.5275 8.102 3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    sleep $2

    echo "ctpq time $2 off 0 pos ($1 30 60.707 51.8791 6.0 12.5275 8.102 3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
    fix_point $2 -29.4 8.4 4.9 -10.8 0.0 5.0
    sleep $2

    echo "ctpq time $2 off 0 pos ($1 30 60.707 51.8791 -14.8 12.5275 8.102 3.23071 70.0 46.8 81.6 54.0 112.4 60.3 83.2 80.0)" | yarp rpc /ctpservice/left_arm/rpc
}

imitate_robot() {
    ENDARM=$(bc <<< "$3+$4")
    i=1
    while [ "$i" -le "$2" ]; do
        echo "ctpq time $1 off 0 pos (-15.8649 30.584 0.00176004 $3 -0.00142396 0.000890493 0.119221 1.2 15.209 0.0672761 0.0200121 0.0240908 0.00724052 0.0210287 0.00672317 0.0203399)" | yarp rpc /ctpservice/left_arm/rpc
        fix_point $1 0.0 0.0 12.0 0.0 0.0 0.0
        sleep $1
        move_eyelids "S55"
        echo "ctpq time $1 off 0 pos (-15.7507 30.584 0.000323085 $3 0.000139115 0.000481608 0.118885 15.002 15.209 0.0672874 0.0202492 0.0240462 0.0071755 0.0209986 0.00668006 0.0328025)" | yarp rpc /ctpservice/right_arm/rpc
        fix_point $1 0.0 0.0 -12.0 0.0 0.0 0.0
        sleep $1
        move_eyelids "S45" 
        
        echo "ctpq time $1 off 0 pos (-15.8649 30.584 0.00176004 $ENDARM -0.00142396 0.000890493 0.119221 1.2 15.209 0.0672761 0.0200121 0.0240908 0.00724052 0.0210287 0.00672317 0.0203399)" | yarp rpc /ctpservice/left_arm/rpc
        fix_point $1 0.0 0.0 12.0 0.0 0.0 0.0
        sleep $1
        move_eyelids "S50"
        echo "ctpq time $1 off 0 pos (-15.7507 30.584 0.000323085 $ENDARM 0.000139115 0.000481608 0.118885 15.002 15.209 0.0672874 0.0202492 0.0240462 0.0071755 0.0209986 0.00668006 0.0328025)" | yarp rpc /ctpservice/right_arm/rpc
        fix_point $1 0.0 0.0 -12.0 0.0 0.0 0.0
        sleep $1
        move_eyelids "S60" 
        i=$(($i + 1))
    done
}

home_left_arm_body() {
    echo "ctpq time 2.0 off 0 pos (-15.8649 22.3947 0.00176004 30.0 -0.00142396 0.000890493 0.119221 59.8433 0.048714 0.0672761 0.0200121 0.0240908 0.00724052 0.0210287 0.00672317 0.0203399)" | yarp rpc /ctpservice/left_arm/rpc
}

home_right_arm_body() {
    echo "ctpq time 2.0 off 0 pos (-15.7507 22.4016 0.000323085 30.0 0.000139115 0.000481608 0.118885 59.8411 0.0486692 0.0672874 0.0202492 0.0240462 0.0071755 0.0209986 0.00668006 0.0328025)" | yarp rpc /ctpservice/right_arm/rpc
}

home_head() {
    echo "ctpq time 2.0 off 0 pos (0.0 0.0 0.0 0.0 0.0 5.0)"  | yarp rpc /ctpservice/head/rpc
}

home_torso() {
    echo "ctpq time 3.0 off 0 pos (0.0 0.0 0.0)"  | yarp rpc /ctpservice/torso/rpc
}

home_left_arm() {
    echo "ctpq time $1 off 0 pos (-29.5 30.0 0.0 44.5 0.0 0.0 0.0 15.0 20.0 20.0 17.0 10.0 13.5 10.0 13.0 5.0)" | yarp rpc /ctpservice/left_arm/rpc
}

home_right_arm() {
    echo "ctpq time $1 off 0 pos (-29.5 30.0 0.0 44.5 0.0 0.0 0.0 57.0 20.0 0.0 0.0 0.0 0.0 0.0 0.0 2.5)" | yarp rpc /ctpservice/right_arm/rpc
}

home_all() {
    # This is with the arms over the table
    home_left_arm 3.0
    home_right_arm 3.0
    home_head
    home_torso
    #neutral
    open_eyes
}

#######################################################################################
# SUB-SCENES FUNCTIONS
#######################################################################################
perform_1_1() {
    close_eyes
    sleep 2.0
    open_eyes  
    sleep 2.0
    squint
    sleep 2.0
    open_eyes
}

perform_1_2() {
    generic_gaze
    #curious
}

perform_8_3() {
    AZIDIR=${1:-1}
    TEYES=${2:-2.5}
    set_speed_eyes $TEYES
    fix_only_eyes $AZIDIR
}

perform_8_4() {
    TARM=${1:-3.0}
    ARM=${2:-left_arm}
    point $TARM $ARM
    gaze "look -20.0 15.0 5.0"
}

perform_8_5() {
    TARM=${1:-1.5}
    ARM=${2:-left_arm}
    point_breast $TARM $ARM
    fix_only_eyes_down
    #sad
}

perform_8_6() {
    TARM=${1:-3.0}
    ARM=${2:-left_arm}
    gaze "look -10.0 -10.0 5.0"
    point_forehead $TARM $ARM
    #happy
}

perform_8_7() {
    START=${1:-0}
    TIME=${2:-0.6}
    nod $START $TIME
}

perform_8_8() {
    TARM=${1:-3.0}
    ARM=${2:-left_arm}
    generic_gaze
    sleep 10.0
    gaze "idle"
    gaze "look -10.0 -25.0 5.0"
    point_glass $TARM $ARM
    sleep 7.0
    clean left_arm 
}

perform_11_9() {
    look_down
    draw_table_right
}

perform_11_10() {
    fix_point 1.5 15 6 16 11 -5.4 5 
}

perform_12_12() {
    AZI=${1:-20.0}
    EL=${2:-10.0}
    gaze "look $AZI $EL 5"
}

perform_13_13_1() {
    EYETILT=${1:-12}
    AZI=${2:-0.0}
    EL=${3:-17.0}
    fix_point 1.5 $EL 0 $AZI $EYETILT 0 10
    sleep 1.5
    #emotion "neu" "sur" "neu"
}

perform_13_13_2() {
    TARM=${1:-1.5}
    arm_sleeve_left $TARM 
    arm_sleeve_right $TARM
}

perform_13_13_3() {
    EYESDIR=${1:-1}
    EYESYAW=$(bc <<< "22*$EYESDIR")
    fix_point 1.5 -28.8956 -3.23077 $EYESYAW -17.978 -0.346534 9.00014
    sleep 0.5
    #neutral
}

perform_13_13() {
    perform_13_13_1
    sleep 1.0
    perform_13_13_2
    sleep 3.0
    perform_13_13_3
}

perform_14_14() {
    look_down
    draw_table_right
}

perform_14_15() {
    TARM=${1:-0.3}
    ARM=${2:-left_arm}
    look_down
    greet $TARM $ARM
}

perform_15_16() {
    TLOOK=${1:-1.5}
    AZI=${2:-20.0}
    EL=${3:-10.0}
    set_speed_eyes 0.75
    set_speed_neck 1
    gaze "look $AZI $EL 5.0"
    sleep 4.0
    look_around_eyes $TLOOK
}

perform_15_17() {
    TARM=${1:-2.0}
    TOPEN=${2:-1.0}
    THIDE=${3:-2.5}
    peek_a_boo $TARM $TOPEN $THIDE
}

perform_15_18() {
    STARTLEFT=${1:-30.0}
    AMPLLEFT=${2:-30.0}
    STARTEYES=${3:-0.0} #${3:--8.0}
    AMPLEYES=${4:--20.0} #${4:--13.0}

    #follow_draw_wall_right $STARTEYES $AMPLEYES
    #draw_wall_wrist_right $STARTLEFT $AMPLLEFT

    #fix_point $DRAW_TIME 0.0274725 0.021978 18.0 0.043956 $STARTEYES 12.0
    #draw_point_left $STARTLEFT
    #TREACT=$(bc <<< "$DRAW_TIME*3")
    #sleep $TREACT
    #follow_draw_line_left $STARTEYES $AMPLEYES
    #draw_line_left $STARTLEFT $AMPLLEFT

    fix_point $DRAW_TIME 0.0274725 0.021978 -18.0 0.043956 $STARTEYES 12.0
    draw_point_right $STARTLEFT
    TREACT=$(bc <<< "$DRAW_TIME*3")
    echo "Treact:" $TREACT
    sleep $TREACT
    follow_draw_line_right $STARTEYES $AMPLEYES
    draw_line_right $STARTLEFT $AMPLLEFT
}

perform_15_20_peluche() {
    STARTHEIGHT=${1:--50.6} 
    TARM=${2:-1.0}
    EYECLOSE=${3:-S50}
    home_left_table_side $STARTHEIGHT
    sleep 3.0
    grasp_trex_left
    sleep 4.0
    follow_trex_left $STARTHEIGHT $TARM $EYECLOSE
}

perform_15_20_toy() {
    STARTHEIGHT=${1:--52.7}
    OFFSET=$(bc <<< "$STARTHEIGHT - 8")
    echo $STARTHEIGHT $OFFSET
    TARM=${2:-1.0}
    EYECLOSE=${3:-S50}
    home_left_table_top $STARTHEIGHT 
    sleep 3.0
    grasp_trex_left
    sleep 3.0
    follow_trex_left $OFFSET $TARM $EYECLOSE
}

perform_15_21() {
    TIME=${1:-1.5}
    NREP=${2:-2}
    START=${3:-55.0}
    AMPL=${4:-20.0}
    imitate_robot $TIME $NREP $START $AMPL
}

perform_17_22() {
    TEYES=${1:-0.75}
    fix_only_eyes_right
    sleep 0.2
    #emotion "neu" "neu" "sur"
    sleep 3.0
    fix_only_eyes_left
    sleep 0.2
    #emotion "hap" "sur" "neu"
    sleep 3.0
    fix_only_eyes_up
    sleep 0.2
    #emotion "neu" "sur" "sur"
    sleep 3.0
    fix_only_eyes_down
    #sad
    sleep 3.0
    #neutral
    close_eyes
    home_head
    sleep 3.0
    open_eyes
    #surprised
    sleep 3.0
    #emotion "neu" "ang"
    squint
    sleep 3.0
}

perform_20_24() {
    EYETILT=${1:-12}
    AZI=${2:--20.0}
    EL=${3:-18.0}
    fix_point 1.5 $EL 0 $AZI $EYETILT 0 10
}

perform_20_25() {
    EYETILT=${1:--15}
    AZI=${2:--20.0}
    EL=${3:--25.0}
    fix_point 1.5 $EL 0 $AZI $EYETILT 0 10
    sleep 0.75
    #sad
}

perform_20() {
    perform_20_24
    sleep 2.0
    perform_20_25
}

perform_22_26() {
    EYETILT=${1:-12}
    AZI=${2:--20.0}
    EL=${3:-17.0}
    fix_point 1.5 $EL 0 $AZI $EYETILT 0 10
}

perform_22_27_1() {
    EYETILT=${1:-12}
    AZI=${2:-20.0}
    EL=${3:-17.0}
    fix_point 1.5 $EL 0 $AZI $EYETILT 0 10
}

perform_22_27_2() {
    fix_point 1.5 -28.8956 -3.23077 22 -17.978 -0.346534 9.00014
    arm_sleeve 3.0 left_arm
    arm_sleeve 3.0 right_arm
}

perform_22_27_3() {
    EYETILT=${1:-12}
    AZI=${2:-20.0}
    EL=${3:-17.0}
    fix_point 1.5 $EL 0 $AZI $EYETILT 0 10
    sleep 0.75
    #emotion "neu" "sur"
}

perform_22_29() {
    TARM=${1:-3.0}
    ARM=${2:-left_arm}
    AZI=${3:-20.0}
    EYETILT=${4:-0}
    EL=${5:-17.0}
    fix_point 1.5 $EL 0 $AZI $EYETILT 0 10
    point_face $TARM $ARM
    #sleep $TARM
    #speak "tob ia"
}

perform_22_30() {
    TARM=${1:-1.5}
    ARM=${2:-left_arm}
    AZI=${3:-20.0}
    EYETILT=${4:-0}
    EL=${5:-0.0}
    fix_point 1.5 $EL 0 $AZI $EYETILT 0 10
    #sad
    #caress $ARM
    caress_elbow $TARM $ARM
}

#######################################################################################
# "MAIN" FUNCTION:                                                                    #
#######################################################################################
echo "********************************************************************************"
echo ""

$1 $2 $3 $4 $5 $6 $7 $8

if [[ $# -eq 0 ]] ; then
    echo "No options were passed!"
    echo ""
    usage
    exit 1
fi
