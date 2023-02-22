#!/bin/bash

# Set default values
period=20000000
duty_cycle=1450000
polarity="normal"
channel=1

# Function for calculating duty cycle from percentage
function get_duty_cycle {
  local dc=$(($1 * $period / 100))
  echo "$dc"
}

# Show help if no arguments are given
if [ $# -eq 0 ]; then
  echo "Usage: $0 [-e channel] [-u channel] [-p period] [-d duty_cycle] [-o polarity] [-n channel] [-f frequency] [-g duty_cycle_percent] [-s channel]"
  echo "  -s channel              Select PWM channel (default: $channel)"
  echo "  -e channel              Export PWM channel"
  echo "  -u channel              Unexport PWM channel"
  echo "  -p period               Set PWM period in nanoseconds (default: $period)"
  echo "  -d duty_cycle           Set PWM duty cycle in nanoseconds (default: $duty_cycle)"
  echo "  -o polarity             Set PWM polarity (normal/inversed) (default: $polarity)"
  echo "  -n channel              Enable PWM signal"
  echo "  -x channel              Disable PWM signal"
  echo "  -f frequency            Set PWM frequency in Hertz"
  echo "  -g duty_cycle_percent   Set PWM duty cycle as a percentage (0-100)"
  exit 1
fi

# Parse arguments
while getopts ":s:e:u:p:d:o:n:x:f:g:" opt; do
  case $opt in
    s)
      channel=$OPTARG
      ;;
    e)
      sudo sh -c "echo $OPTARG > /sys/class/pwm/pwmchip0/export"
      ;;
    u)
      sudo sh -c "echo $OPTARG > /sys/class/pwm/pwmchip0/unexport"
      ;;
    p)
      period=$OPTARG
      sudo sh -c "echo $period > /sys/class/pwm/pwmchip0/pwm$channel/period"
      ;;
    d)
      duty_cycle=$OPTARG
      sudo sh -c "echo $duty_cycle > /sys/class/pwm/pwmchip0/pwm$channel/duty_cycle"
      ;;
    o)
      polarity=$OPTARG
      sudo sh -c "echo $polarity > /sys/class/pwm/pwmchip0/pwm$channel/polarity"
      ;;
    n)
      sudo sh -c "echo 1 > /sys/class/pwm/pwmchip0/pwm$OPTARG/enable"
      ;;
	x)
      sudo sh -c "echo 0 > /sys/class/pwm/pwmchip0/pwm$OPTARG/enable"
      ;;
    f)
      frequency=$OPTARG
      period=$(echo "scale=0; 1000000000 / $frequency" | bc)
      sudo sh -c "echo $period > /sys/class/pwm/pwmchip0/pwm$channel/period"
      ;;
    g)
      duty_cycle_percent=$OPTARG
      duty_cycle=$(get_duty_cycle $duty_cycle_percent)
      sudo sh -c "echo $duty_cycle > /sys/class/pwm/pwmchip0/pwm$channel/duty_cycle"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# END PROGRAM
