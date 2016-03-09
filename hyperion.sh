#!/bin/bash
# Init
ip="mydomain.com"
user="myUser"
port="22"
ssh="ssh $user@$ip -p $port"
remote="-t hyperion-remote"
service="hyperion"

function level {
	if [[ "${2}" =~ ^[0-9]* ]] && ! [[ "${2}" == [a-zA-Z] ]] && (( "${2}" >= 0 && "${2}" <= 10 ));
	then # between [0-10]
		printf "Setting the level to "${2}"\n\n"
		echo $result
		curl --request POST "${ip}:1234/set_value_gain" --data "valueGain=${2}"
	else
	    printf ""${red}"Error: Not a valid number (0-10)"${nc}"\n"; exit 1
	fi
}

## Colors
function color {
	curl --request POST "${ip}:1234/set_color_name" --data "colorName=${2}"
	printf "\nSetting the color to ${2}\n\n"
}

function fetchColors {
	file="colors"
	printf "Fetching colors...\n"
	${ssh} ${remote} "$( cat <<EOF
		-c --list
EOF
)" 2>/dev/null | tail -n +2 | sed 's/^ *//' | tr -d '\r' > colors.txt
# tail: Removes the error output (1st line),
# sed: removes the space on every new line,
# tr: removes Windows line endings.
	length=$(wc -l < "${file}.txt")
}

function colorRGB {
	if [[ "${2}" =~ ^[0-9]* ]] && ! [[ "${2}" == [a-zA-Z] ]] &&
		(( "${2}" >= 0 && "${2}" <= 255 )) &&
		[[ "${3}" =~ ^[0-9]* ]] && ! [[ "${3}" == [a-zA-Z] ]] &&
		(( "${3}" >= 0 && "${3}" <= 255 )) &&
		[[ "${4}" =~ ^[0-9]* ]] && ! [[ "${4}" == [a-zA-Z] ]] &&
		(( "${4}" >= 0 && "${4}" <= 255 )); then
		printf "\ntest\n\n"
		curl --request POST "${ip}:1234/set_static" --data "r=${2}&g=${3}&b=${4}"
		printf "\nSetting the color to ${2} ${3} ${4}\n\n"
	else
	    printf ""${red}"Error: Not a valid number (0-255)"${nc}"\n"; exit 1
	fi
}

function colorlist {
	fetchColors
	cat -n colors.txt # prints numbers on each line

	# Choose a line
	while true; do
	    read -p "What color would you like? " num
	    size=${#num}
	    if [[ $size > 0 ]] && [[ ${num} =~ ^[0-9]* ]] &&
	    	(( ${num} >= 1 )) && (( ${num} <= $length )); then
	        color=$(parseFile ${num})
	        printf "You choose: "${color}"\n\n"
			curl --request POST "${ip}:1234/set_color_name" --data "colorName=${color}"

	    else
	        printf ""${red}"Error: Could not find color number "${num}""${nc}"\n\n"
	    fi
	done
}

function colorNum {
	fetchColors > /dev/null 2>&1
    if [[ ${val} =~ ^[0-9]* ]] && (( ${val} >= 1 )) && (( ${val} <= ${length} )); then
        color=$(parseFile ${val})
        printf "You choose: "${color}"\n"
		curl --request POST "${ip}:1234/set_color_name" --data "colorName=${color}"

    else
        printf ""${red}"Error: Could not find color number ${num}"${nc}"\n\n"
    fi
}

## Effects
function effect {
	curl --request POST "${ip}:1234/set_effect" --data "effect=${2}"
	printf "\nYou choose: "${OPTARG}"\n"
}

function fetchEffects {
	file="effects"
	printf "\nFetching effects...\n"
	${ssh} ${remote} "$( cat <<EOF
		-l | grep -v hostname | grep name
EOF
)" 2>/dev/null | sed s/'         "name"'// | tr -d "\,\":" | sed 's/^ *//' | tr -d '\r'>effects.txt
# First part removes some spacing and the "name".
# The second removes the commas and the third removes the space on every new line

	length=$(wc -l < "${file}.txt")
}

function effectlist {
	fetchEffects > /dev/null 2>&1
	printf "\n\n"
	cat -n effects.txt # prints numbers on each line


	# Choose a line
	while true; do
		printf "\n\n"
	    read -p "What effect would you like? " num
	    size=${#num}
	    if [[ $size > 0 ]] && [[ ${num} =~ ^[0-9]* ]] &&
	    	(( ${num} >= 1 )) && (( ${num} <= ${length} )); then
	        effect=$(parseFile ${num})

	        #send string with spaces
	        IFS=$'\n'; array=($(echo $effect | egrep -o '"[^"]*"|\S+'))
	        printf "You choose: "$effect"\n\n"
			curl --request POST "${ip}:1234/set_effect" --data "effect="${effect}""
	    else
	        printf ""${red}"Error: Could not find effect number ${num}"${nc}"\n\n"
	    fi
	done

}

function effectNum {
	fetchEffects > /dev/null 2>&1
    if [[ $val =~ ^[0-9]* ]] && (( ${val} >= 1 )) && (( ${val} <= ${length} )); then
        effect=$(parseFile ${val})
        printf "\nYou choose: "${effect}"\n"
		curl --request POST "${ip}:1234/set_effect" --data "effect=${effect}"
    else
        printf ""${red}"Error: Could not find effect number ${num}"${nc}"\n\n"
    fi
}

# Help function
function parseFile {
	cat $file.txt | head -"$1" | tail -1
}


function clear {
	curl --request POST "${ip}:1234/do_clear" --data "clear=clear"
	printf "Cleared all priority channels\n"
}

function restart {
	curl --request POST "${ip}:1234/do_restart" --data "restart=restart"
	printf ""${service}" restarted\n"
}

function start {
	curl --request POST "${ip}:1234/do_start" --data "start=start"
	printf ""${service}" started\n"
}

function stop {
	curl --request POST "${ip}:1234/do_stop" --data "stop=stop"
	printf ""${service}" stopped\n"
}

function usage {
    cat <<EOF
    This script controls LEDS via the Hyperion Web UI service.
    Usage: $0 <arguments>

    OPTIONS:
       -h      Show this message.
       -c      Choose a color of your choice by RBG code.
       -v      Choose a power level (0-10).
       -x      Clear all channels.

       Other tools:
       -r      Restarts the $service service.
       -s      Starts the $service service.
       -p      Stops the $service service.
EOF
}

optspec="hxspr-:c:v:e:"
while getopts "${optspec}" optchar; do
	case "${optchar}" in

		h) 
		   usage
		   exit 1 ;;

		c) color ${@} ;;

		v) level ${@} ;;

		e) effect ${@} ;;

		x) clear ;;

		s) start ;;

		p) stop ;;

		r) restart ;;

		-)
			case "${OPTARG}" in
				help)
					usage
					exit 1 ;;

                fetchColors)
					fetchColors
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;

                fetchEffects)
					fetchEffects
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                    

				colorRGB)
					echo $@
					colorRGB ${@}
					;;

                colorlist)
					colorlist
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;

                colorNum)
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    fetchColors
				    if [[ ${val} > 0 ]] && [[ ${val} =~ ^[0-9]* ]] &&
				    	(( ${val} >= 1 )) && (( ${val} <= ${length} )); then
                    	printf "\n"${red}"You have to write \""${nc}"
                    		--${OPTARG}=${val}"${red}"\"!"${nc}"\n\n" >&2;
                	else
                		printf "\n"${red}"You have to write \""${nc}"
                			--${OPTARG}=(value)"${red}"\"!"${nc}"\n\n" >&2;
                	fi
                    ;;

                colorNum=*) # effectNum with argument
                    val=${OPTARG#*=}
                    opt=${OPTARG%=$val}
					colorNum ${val}
                    ;;

                effectlist)
					effectlist
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;

                effectNum=*) # effectNum with argument
                    val=${OPTARG#*=}
                    opt=${OPTARG%=$val}
					effectNum ${val}
                    ;;

                *)
                    if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                        printf "Unknown option --${OPTARG}" >&2
                    fi
                    ;;
            esac;;

        *)
			usage
			exit 1
            ;;
	esac
done
exit 0