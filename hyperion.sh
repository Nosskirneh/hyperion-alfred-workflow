#!/bin/bash
# Init
ip="192.168.0.120"
user="root"
port="22"
ssh="ssh $user@$ip -p $port"
pri="0" # Hyperion iOS app uses priority 0
remote="-t hyperion-remote"
service="hyperion"

# Output colors
red='\033[0;31m'
nc='\033[0m' # No color
u_yellow='\e[4;33m'
yellow='\e[0;33m'



# No touching below this point
debugString="+debug"
debug="0"
if [ "${@: -1}" == "${debugString}" ]; then
	debug="1"
	printf "############### debug FLAG DETECTED! ###############\n"
	printf "# ip: "${yellow}"$ip"${nc}"                                #\n"
	printf "# port: "${yellow}"$port"${nc}"                                         #\n"
	printf "# user: "${yellow}"$user"${nc}"                                       #\n"
	printf "# service: "${yellow}"$service"${nc}"                                #\n"
	printf "# priority: "${yellow}""${pri}""${nc}" (lower number => higher priority)    #\n"
	printf "####################################################\n\n"
fi


function level {
	if [[ "${OPTARG}" =~ ^[0-9]* ]] && (( "${OPTARG}" >= 0 && "${OPTARG}" <= 10 )); then # between [0-10]
		result=$(echo ""${OPTARG}"/10" | bc -l)
		printf "Setting the level to "${OPTARG}"\n\n"

		cmd=""${ssh}" "${remote}" -v "${result}""
		if [[ "${debug}" == 1 ]]; then
			printf "\n"${u_yellow}"[DEBUG] Returned from host:"${nc}"\n"
			${cmd}
			printf ""${yellow}"[DEBUG] End of log."${nc}"\n"
		else
			${cmd} > /dev/null 2>&1
		fi

	else
	    printf ""${red}"Error: Not a valid number (0-10)"${nc}"\n"; exit 1
	fi
}



### COLORS ###
function color {
		cmd=""${ssh}" "${remote}" -c "${OPTARG}" -p "${pri}""
		printf "Setting the color to "${OPTARG}"\n\n"

		if [[ ${debug} == 1 ]]; then
			printf "\n"${u_yellow}"[DEBUG] Returned from host:"${nc}"\n"
			${cmd}
			printf ""${yellow}"[DEBUG] End of log."${nc}"\n"
		else
			${cmd} > /dev/null 2>&1
		fi
}

function fetchColors {
	file="colors"
	printf "Fetching colors...\n"
	${ssh} ${remote} "$( cat <<EOF
		-c --list
EOF
)" 2>/dev/null | tail -n +2 | sed 's/^ *//' | tr -d '\r' > colors.txt # (tail) Removes the error output (1st line), (sed) removes the space on every new line, (tr) removes Windows line endings.
	length=$(wc -l < "${file}.txt")
}

function colorlist {
	fetchColors
	cat -n colors.txt # prints numbers on each line

	# Choose a line
	while true; do
	    read -p "What color would you like? " num
	    size=${#num}
	    if [[ $size > 0 ]] && [[ ${num} =~ ^[0-9]* ]] && (( ${num} >= 1 )) && (( ${num} <= $length )); then
	        color=$(parseFile ${num})
	        printf "You choose: "${color}"\n\n"

			cmd=""${ssh}" "${remote}" -c "${color}" -p "${pri}""
			if [[ ${debug} == 1 ]]; then
				printf "\n"${u_yellow}"[DEBUG] Returned from host:"${nc}"\n"
				${cmd}
				printf ""${yellow}"[DEBUG] End of log."${nc}"\n"
			else
				${cmd} > /dev/null 2>&1
			fi

	    else
	        printf ""${red}"Error: Could not find color number "${num}""${nc}"\n\n"
	    fi
	done
}

function colorNum () {
	fetchColors > /dev/null 2>&1
    if [[ ${val} =~ ^[0-9]* ]] && (( ${val} >= 1 )) && (( ${val} <= ${length} )); then
        color=$(parseFile ${val})
        printf "You choose: "${color}"\n"
		cmd=""${ssh}" "${remote}" -c "${color}" -p "${pri}""
		echo ${cmd}
		if [[ ${debug} == 1 ]]; then
			printf "\n"${u_yellow}"[DEBUG] Returned from host:"${nc}"\n"
			${cmd}
			printf ""${yellow}"[DEBUG] End of log."${nc}"\n"
		else
			${cmd} > /dev/null 2>&1
		fi

    else
        printf ""${red}"Error: Could not find color number ${num}"${nc}"\n\n"
    fi
}





### EFFECTS ###
function effect {
	fetchEffects > /dev/null 2>&1

	    printf "You choose: "${OPTARG}"\n\n"
		cmd=""${ssh}" "${remote}" -e '""${OPTARG}""' -p "${pri}""
		if [[ ${debug} == 1 ]]; then
			printf "\n"${u_yellow}"[DEBUG] Returned from host:"${nc}"\n"
			${cmd}
			printf ""${yellow}"[DEBUG] End of log."${nc}"\n"
		else
			${cmd} > /dev/null 2>&1
		fi
}

function fetchEffects {
	file="effects"
	printf "Fetching effects...\n"
	${ssh} ${remote} "$( cat <<EOF
		-l | grep -v hostname | grep name
EOF
)" 2>/dev/null | sed s/'         "name"'// | tr -d "\,:" | sed 's/^ *//' | tr -d '\r' > effects.txt
# First part removes some spacing and the "name". The second removes the commas and the third removes the space on every new line
	length=$(wc -l < "${file}.txt")
}

function effectlist {
	fetchEffects > /dev/null 2>&1
	printf "\n\n"
	cat -n effects.txt # prints numbers on each line
	printf "\n\n"


	# Choose a line
	while true; do
	    read -p "What effect would you like? " num
	    size=${#num}
	    if [[ $size > 0 ]] && [[ ${num} =~ ^[0-9]* ]] && (( ${num} >= 1 )) && (( ${num} <= ${length} )); then
	        effect=$(parseFile ${num})
	        printf "You choose: "${effect}"\n\n"

			cmd=""${ssh}" "${remote}" -e "${effect}" -p "${pri}""
			if [[ ${debug} == 1 ]]; then
				printf "\n"${u_yellow}"[DEBUG] Returned from host:"${nc}"\n"
				${cmd}
				printf "$"{yellow}"[DEBUG] End of log."${nc}"\n"
			else
				${cmd} > /dev/null 2>&1
			fi

	    else
	        printf ""${red}"Error: Could not find effect number ${num}"${nc}"\n\n"
	    fi
	done

}

function effectNum () {
	fetchEffects > /dev/null 2>&1
    if [[ $val =~ ^[0-9]* ]] && (( ${val} >= 1 )) && (( ${val} <= ${length} )); then
        effect=$(parseFile ${val})
        printf "You choose: "${effect}"\n"

		cmd=""${ssh}" "${remote}" -e "${effect}" -p "${pri}""
		if [[ ${debug} == 1 ]]; then
			printf "\n"${u_yellow}"[DEBUG] Returned from host:"${nc}"\n"
			${cmd}
			printf ""${yellow}"[DEBUG] End of log."${nc}"\n"
		else
			${cmd} > /dev/null 2>&1
		fi

    else
        printf ""${red}"Error: Could not find effect number ${num}"${nc}"\n\n"
    fi
}


# Help function
function parseFile () {
	cat $file.txt | head -"$1" | tail -1
}






### OTHER TOOLS ###
function clear {
	cmd=""${ssh}" "${remote}" --clearall"
	if [[ ${debug} == 1 ]]; then
		printf "\n"${u_yellow}"[DEBUG] Returned from host:"${nc}"\n"
		${cmd}
		printf ""${yellow}"[DEBUG] End of log."${nc}"\n"
	else
		${cmd} > /dev/null 2>&1
	fi
	printf "Cleared all priority channels\n"
}

function start {
	${ssh} <<EOF > /dev/null 2>&1
	[ -f /storage/.cache/services/$service.disabled ] && mv /storage/.cache/services/$service.disabled /storage/.cache/services/$service.conf
	[ ! -f /storage/.cache/services/$service.conf ] && touch /storage/.cache/services/$service.conf
	systemctl start $service
EOF

	printf ""${service}" started\n"
}


function stop {
	${ssh} <<EOF > /dev/null 2>&1
		/storage/hyperion/bin/hyperion-remote.sh --priority 0 --color black && sleep 1 && systemctl stop $service
		[ -f /storage/.cache/services/$service.conf ] && mv /storage/.cache/services/$service.conf /storage/.cache/services/$service.disabled
EOF

	printf ""${service}" stopped\n"
}


function restart {
	${ssh} <<EOF > /dev/null 2>&1
	systemctl stop $service
	[ -f /storage/.cache/services/$service.conf ] && mv /storage/.cache/services/$service.conf /storage/.cache/services/$service.disabled

	# Starting again...
	[ -f /storage/.cache/services/$service.disabled ] && mv /storage/.cache/services/$service.disabled /storage/.cache/services/$service.conf
	[ ! -f /storage/.cache/services/$service.conf ] && touch /storage/.cache/services/$service.conf
	systemctl start $service
EOF

	printf ""${service}" restarted\n"
}


function usage {
    cat <<EOF
    This script controls LEDS through the Hyperion service.
    Usage: $0 <arguments>

    OPTIONS:
       Commonly used tools:
       -h      Show this message.
       -c      Choose a color of your choice either by name or by HEX code.
       -v      Choose a power level (0-10).
       -e      Choose an effect by its name (use quotation marks).

       Other tools:
       -x      Clear all channels.
       -s      Starts the $service service.
       -p      Stops the $service service.
       -r      Restarts the $service service.

       Special tools:
       --effectlist		Choose an effect from a list of all possible effects available.
       --effectNum=(value)	Choose an effect directly by its number in the list of `printf "\e[3m--effectlist\e[0m"`.
       --colorlist		Choose a color from a list all possible colors available.
       --colorNum=(value)	Choose an effect by its number in the list of `printf "\e[3m--colorlist\e[0m"`.
EOF
}


optspec="hxspr-:c:v:e:"
while getopts "${optspec}" optchar; do
	case "${optchar}" in

		h) 
		   usage
		   exit 1 ;;

		c) color "${OPTARG}" ;;

		v) level "${OPTARG}" ;;

		e) effect "${OPTARG}" ;;

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


                colorlist)
					colorlist
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;

                colorNum)
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    fetchColors
				    if [[ ${val} > 0 ]] && [[ ${val} =~ ^[0-9]* ]] && (( ${val} >= 1 )) && (( ${val} <= ${length} )); then
                    	printf "\n"${red}"You have to write \""${nc}"--${OPTARG}=${val}"${red}"\"!"${nc}"\n\n" >&2;
                	else
                		printf "\n"${red}"You have to write \""${nc}"--${OPTARG}=(value)"${red}"\"!"${nc}"\n\n" >&2;
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

                effectNum)
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    fetchEffects
				    if [[ $size > 0 ]] && [[ ${val} =~ ^[0-9]* ]] && (( ${val} >= 1 )) && (( ${val} <= ${length} )); then
                    	printf "\n"${red}"You have to write \""${nc}"--${OPTARG}=${val}"${red}"\"!"${nc}"\n\n" >&2;
                	else
                		printf "\n"${red}"You have to write \""${nc}"--${OPTARG}=(value)"${red}"\"!"${nc}"\n\n" >&2;
                	fi
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
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
				printf "Non-option argument: '-${OPTARG}'" >&2
				usage
				exit 1
            fi
            ;;

	esac
done


exit 0