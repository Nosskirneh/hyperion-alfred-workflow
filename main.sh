#!/bin/bash
source ./workflowHandler.sh

num='^[0-9]'
fullarg=$@
arg1=`echo $1 | awk '{print $1;}'` # Example: color
arg2=`echo $fullarg | awk '{print $2;}'` #Example: red

if [[ ${arg1} == "color" ]]; then # Color items
	if [[ red == ${arg2}* ]]; then
		color="red"
		addResult ""${color}"" "-c "${color}"" ""${color}"" "Change the color to "${color}"" "icons/"${color}"_128.png" "yes" "color "${color}""
	fi
	if [[ blue == ${arg2}* ]]; then
		color="blue"
		addResult ""${color}"" "-c "${color}"" ""${color}"" "Change the color to "${color}"" "icons/"${color}"_128.png" "yes" "color "${color}""
	fi
	if [[ cyan == ${arg2}* ]]; then
		color="cyan"
		addResult ""${color}"" "-c "${color}"" ""${color}"" "Change the color to "${color}"" "icons/"${color}"_128.png" "yes" "color "${color}""
	fi
	if [[ green == ${arg2}* ]]; then
		color="green"
		addResult ""${color}"" "-c "${color}"" ""${color}"" "Change the color to "${color}"" "icons/"${color}"_128.png" "yes" "color "${color}""
	fi
	if [[ yellow == ${arg2}* ]]; then
		color="yellow"
		addResult ""${color}"" "-c "${color}"" ""${color}"" "Change the color to "${color}"" "icons/"${color}"_128.png" "yes" "color "${color}""
	fi
	if [[ black == ${arg2}* ]]; then
		color="black"
		addResult ""${color}"" "-c "${color}"" ""${color}"" "Change the color to "${color}"" "icons/"${color}"_128.png" "yes" "color "${color}""
	fi
	if [[ purple == ${arg2}* ]]; then
		color="purple"
		addResult ""${color}"" "-c "${color}"" ""${color}"" "Change the color to "${color}"" "icons/"${color}"_128.png" "yes" "color "${color}""
	fi


elif [[ ${arg1} == "level" ]]; then # Level items
	size=${#arg2}
	#echo ${arg2}
	if [[ ${arg2} =~ ${num} ]] && [[ ${arg2} ]] && [[ ${arg2} -lt 11 ]] && [[ ${arg2} -gt -1 ]]; then
		addResult ""${arg2}"" "-v "${arg2}"" "Set the level to "${arg2}"" "" "icons/check_128.png" "yes" "level "${arg2}""
	elif [[ ${arg2} -gt 10 ]] || [[ ${size} > 0 ]]; then
		addResult ""${arg2}"" "" ""${arg2}" is not a valid number! [0-10]" "" "icons/cross_128.png" "no" "level "${arg2}""
	else
		addResult ""${arg2}"" "" "Enter a number [0-10]" "" "icons/level_128.png" "no" "level "${arg2}""
	fi


elif [[ ${arg1} == "effect" ]]; then # Effect items
	./hyperion.sh --fetchEffects > /dev/null 2>&1
	sed -i '' s/\"//g effects.txt # without quotes
	length=$(wc -l < "effects.txt")
	for (( n=1; n<=$length; n++))
	do
  		effect=$(sed -n "${n}{p;q;}" effects.txt)
		addResult "uid" "--effectNum="$n"" "$effect" "" "icons/effect_128.png" "yes" "effect "$effect""
	done
	
elif [[ ${arg1} == "colorlist" ]]; then # Colorlist items
	#./hyperion.sh --fetchColors > /dev/null 2>&1 # not working
	for color in $(<colors.txt); do
		if [[ ${color} == ${arg2}* ]]; then
			addResult ""${color}"" "-c "${color}"" ""${color}"" "" "icons/color_128.png" "yes" "color "${color}""
		fi
	done

else # Main menu items
	if [[ color == ${arg1}* ]]; then
		addResult "1" "" "color" "Change the color from a few ones" "icons/color_128.png" "no" "color "
	fi

	if [[ level == ${arg1}* ]]; then
		addResult "2" "" "level" "Change the level [0-10]" "icons/level_128.png" "no" "level "
	fi

	if [[ effect == ${arg1}* ]]; then
		addResult "3" "" "effect" "Run an effect" "icons/effect_128.png" "no" "effect "
	fi

	if [[ colorlist == ${arg1}* ]]; then
		addResult "4" "" "colorlist" "Choose a color from a list of all available (slow)" "icons/colorlist_128.png" "no" "colorlist "
	fi

	if [[ restart == ${arg1}* ]]; then
		addResult "5" "-r" "restart" "Restart Hyperion" "icons/restart_128.png" "yes" "restart"
	fi

	if [[ start == ${arg1}* ]]; then
		addResult "6" "-s" "start" "Start Hyperion" "icons/start_128.png" "yes" "start"
	fi

	if [[ stop == ${arg1}* ]]; then
		addResult "7" "-p" "stop" "Stop Hyperion" "icons/stop_128.png" "yes" "stop"
	fi

	if [[ clear == ${arg1}* ]]; then
		addResult "8" "-x" "clear" "Clear all priority channels" "icons/clear_128.png" "yes" "clear"
	fi

fi



getXMLResults # return items to Alfred