#!/bin/bash

# Constants
GPIO_PATH="/sys/class/gpio/"
EX="Exported"
UEX="UNexported"
WDO="Written direction of"

# Functions
cgp() { 
    # Check if the GPIO pin is already exported
    [ -d "$GPIO_PATH/gpio$1" ] && echo "$1 already $EX" || echo "$1 not $EX"
    echo "endC"
}

egp() { 
    # Export the GPIO pin
    [ -d "$GPIO_PATH/gpio$1" ] || echo $1 > /sys/class/gpio/export
    echo "$1 $EX func. endE"
}

ugp() { 
    # Unexport the GPIO pin
    [ -d "$GPIO_PATH/gpio$1" ] && echo $1 > /sys/class/gpio/unexport
    echo "$1 $UEX"
}

rgp() {
    # Read the value of the GPIO pin
    egp $1
    sleep 0.1 # Wait for the system to configure the pin
    echo "in" > "$GPIO_PATH/gpio$1/direction" || { echo "Failed to set direction of $1"; exit 1; }
    echo "$WDO $1"
    cat "$GPIO_PATH/gpio$1/value" || { echo "Failed to read value of $1"; exit 1; }
    ugp $1
    echo "endR"
}

wgp() {
    # Write a value to the GPIO pin
    egp $1
    sleep 0.1 # Wait for the system to configure the pin
    echo "out" > "$GPIO_PATH/gpio$1/direction" || { echo "Failed to set direction of $1"; exit 1; }
    echo "$WDO $1"
    echo "$2" > "$GPIO_PATH/gpio$1/value" || { echo "Failed to write value $2 to $1"; exit 1; }
    echo "Setted $1 $2. Not $UEX. endW"
}

# Check for command line arguments
if [ $# -eq 0 ]
then
    echo "Usage: script.sh [-r pin] [-w pin -v value] [-e pin] [-u pin]"
    exit 1
fi

# Parse command line arguments
while getopts ":r:w:v:e:u:" opt; do
    case $opt in
        r) rgp $OPTARG ;;
        w) PIN=$OPTARG ;;
        v) VALUE=$OPTARG ;;
        e) egp $OPTARG ;;
        u) ugp $OPTARG ;;
        ?) echo "Invalid option -$OPTARG" >&2 ;;
    esac
done

# Call write function if -w argument was passed
if [[ $PIN && $VALUE ]]; then
    wgp $PIN $VALUE
fi

exit 0