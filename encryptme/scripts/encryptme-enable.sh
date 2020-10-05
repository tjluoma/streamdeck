#!/usr/bin/env zsh -f
# Purpose: enable EncryptMe (not just running, but actively securing connection)
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2019-09-11

NAME="$0:t:r"

if [[ -e "$HOME/.path" ]]
then
	source "$HOME/.path"
else
	PATH="/usr/local/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin"
fi

function fail {
	MSG="$@"
	echo "$NAME: $MSG" >>/dev/stderr
	growlnotify --sticky --appIcon "EncryptMe" --identifier "$NAME" --message "$MSG" --title "$NAME"
	exit 2
}

function die {
	MSG="$@"
	echo "$NAME: $MSG" >>/dev/stderr
	growlnotify --sticky --appIcon "EncryptMe" --identifier "$NAME" --message "$MSG" --title "$NAME"
	exit 1
}

function msg {
	MSG="$@"
	echo "$NAME: $MSG"
	growlnotify --appIcon "EncryptMe" --identifier "$NAME" --message "$MSG" --title "$NAME"
}

APP1='/Volumes/Applications/EncryptMe.app'
APP2='/Applications/EncryptMe.app'

if [ ! -d "$APP1" -a ! -d "$APP2" ]
then
	fail "No app found at '$APP1' or '$APP2'."

elif [[ -d "$APP1" ]]
then
	APP="$APP1"
else
	APP="$APP2"
fi

pgrep -qx "$APP:t:r"

EXIT="$?"

if [ "$EXIT" != "0" ]
then
	msg "launching '$APP:t:r' ..."
	open -a "$APP:t:r"
	sleep 10
fi

STATUS=$(osascript -e 'tell application "EncryptMe" to enabled')

if [[ "$STATUS" == "true" ]]
then
	msg "EncryptMe is already enabled."
	exit 0
fi

	## I just happened to see this in ~/Library/Preferences/com.bourgeoisbits.cloak.agent.plist
	## as the assigned value when I have set my preferred key which is ⌘ ⇧ ⌥ ⌃ E
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
	fail "HotKey value is supposed to be '$REQUIRED_HOTKEY_VALUE' but is '$ACTUAL_HOTKEY_VALUE'."
fi

STATUS=$(osascript -e 'tell application "EncryptMe" to enabled')

if [[ "$STATUS" == "true" ]]
then
	msg "EncryptMe is running and enabled."
	exit 0
fi

die "Failed to enable EncryptMe"

exit 1
#EOF
