#!/usr/bin/env zsh -f
# Purpose: Check / Control EncryptMe (for use with Keyboard Maestro and a Stream Deck)
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2020-04-13


### NOTE! There is part of this you MUST CONFIGURE ON YOUR OWN
###
### EncryptMe allows you to set a Global Shortcut which they refer to as a 'HotKey'
###
### This 'HotKey' allows you to toggle EncryptMe's encryption ON or OFF when you press it
### and this script RELIES ON that HotKey being set to a particular keyboard combination
###
### Now, the DEFAULT for this is Command+Shift+Option+C
### but that is NOT what I use.
###
### I use Command+Shift+Option+Control+E (⌘ ⇧ ⌥ ⌃ E)
###
### In order for this to work, you have to use the same 'HotKey'
### _or_ edit the script below.
###
### I recommend that you just use mine unless you're already using it for something
### and feel confident that you can edit this script.
###
### How To Set It Up:
###
### 1. Quit EncryptMe.app
###
### 2. Copy/Paste this line into Terminal (without the '###'):
###		defaults write com.bourgeoisbits.cloak.agent HotKey 452984846
###
### 3. Restart EncryptMe.app
###
### 4. You can check EncryptMe.app's preferences if you want to confirm


###
### If you really insist on changing it, enter this line in Terminal.app:
###
###		defaults read com.bourgeoisbits.cloak.agent HotKey
###
###	and record the number that it gives you, and replace '452984846'
### later in this script with it
###
### You will ALSO need to change the 'function trigger-hotkey' below.
###







NAME="$0:t:r"

if [[ -e "$HOME/.path" ]]
then
	source "$HOME/.path"
else
	PATH="/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin"
fi

INSTALL_TO='/Applications/EncryptMe.app'

if [[ ! -d "$INSTALL_TO" ]]
then
	echo "$NAME: '$INSTALL_TO' does not exist."
	exit 2
fi


PID=$(pgrep -i EncryptMe)

if [[ "$PID" == "" ]]
then
		# if that app is installed, it can hardly be said to be enabled or disabled
		# but obviously the user is curious and may want to enable it
		# so let's launch the app if it isn't running
	open -g -j "$INSTALL_TO"
	sleep 5
fi

function get-status {

	STATUS=$(osascript -e 'tell application "EncryptMe" to enabled')

}

function km-set-enabled {

	osascript -e 'tell application "Keyboard Maestro Engine" to do script "E7987644-0F81-4E93-B444-D7E18297FC29" with parameter "Enabled"'

}

function trigger-hotkey {

	## Note: if you wanted to use the default keyboard shortcut, you would need to use this
	#	osascript -e 'tell application "System Events" to keystroke "c" using {command down, shift down, option down}'
	## and you could probably delete everything else in this function

		## This is the value returned when the preference has been set to  ⌘ ⇧ ⌥ ⌃ E
	REQUIRED_HOTKEY_VALUE='452984846'

		## check to see if the value is what it should be
	ACTUAL_HOTKEY_VALUE=$(defaults read com.bourgeoisbits.cloak.agent HotKey 2>/dev/null || echo '0')

	if [[ "$ACTUAL_HOTKEY_VALUE" == "$REQUIRED_HOTKEY_VALUE" ]]
	then
			# Triggering my keyboard shortcut, if it is assigned properly
		osascript -e 'tell application "System Events" to keystroke "e" using {command down, shift down, option down, control down}'

			# give it a few seconds to activate
		sleep 2

	else

		echo "$NAME: EncryptMe's 'HotKey' setting is supposed to be '$REQUIRED_HOTKEY_VALUE' but is '$ACTUAL_HOTKEY_VALUE'."
		echo "$NAME: Please read the note at the top of '$0' for more information."
		exit 2

	fi
}



function km-set-disabled {

	osascript -e 'tell application "Keyboard Maestro Engine" to do script "E7987644-0F81-4E93-B444-D7E18297FC29" with parameter "Disabled"'

}


function km-set-unknown {

	osascript -e 'tell application "Keyboard Maestro Engine" to do script "E7987644-0F81-4E93-B444-D7E18297FC29" with parameter "Unknown"'

}


function encryptme-disable {

	get-status

	if [[ "$STATUS" == "false" ]]
	then
			# is already disabled, so we don't need to do anything
			# but we might as well make sure the Keyboard Maestro / Stream Deck info is accurate
		echo "$NAME: EncryptMe was already disabled"

		km-set-disabled

	else

		trigger-hotkey

		get-status

		if [[ "$STATUS" == "false" ]]
		then
			echo "$NAME: EncryptMe is now disabled"
			km-set-disabled
		else
			echo "$NAME: Failed to disable EncryptMe"
		fi

	fi

}


function encryptme-enable {

	get-status

	if [[ "$STATUS" == "true" ]]
	then
			# is already enabled, so we don't need to do anything
			# but we might as well make sure the Keyboard Maestro / Stream Deck info is accurate
		echo "$NAME: EncryptMe was already enabled"

		km-set-enabled

	else

		trigger-hotkey

		get-status

		if [[ "$STATUS" == "true" ]]
		then
			echo "$NAME: EncryptMe is now enabled"
			km-set-enabled
		else
			echo "$NAME: Failed to enable EncryptMe"
		fi
	fi

}

function encryptme-toggle {

	get-status

	case "$STATUS" in
		false)

			encryptme-enable

		;;

		true)

			encryptme-disable

		;;

		*)
			echo "$NAME: Status Unknown" "$STATUS"
			exit 2
		;;

	esac
}


function encryptme-status {

		# this will be the default action
		# don't change anything,
		# just report what is

	get-status

	case "$STATUS" in
		false)
				km-set-disabled

				echo "$NAME: EncryptMe is disabled"
		;;

		true)
				km-set-enabled
				echo "$NAME: EncryptMe is enabled"
		;;

		*)
				km-set-unknown
				echo "$NAME: EncryptMe status unclear: '$STATUS'."
		;;

	esac
}



################

if [[ "$#" == "0" ]]
then
	encryptme-status
	exit 0
fi

case "$1" in
	status)
		encryptme-status
	;;

	toggle)
		encryptme-toggle
	;;

	enable)
		encryptme-enable
	;;

	disable)
		encryptme-disable
	;;

	*)
		echo "$NAME: Don't know what to do with '$1'. Options are: status, toggle, enable, disable"
		echo "$NAME: If no argument is given 'status' will be returned."
		exit 1
	;;


esac


exit 0
#EOF
