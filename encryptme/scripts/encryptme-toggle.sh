#!/usr/bin/env zsh -f
# Purpose: Change the status of EncryptMe and update the Stream Deck Button
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2020-04-13

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

STATUS=$(osascript -e 'tell application "EncryptMe" to enabled')

case "$STATUS" in
	false)

		msg "Enabling..."

		encryptme-enable.sh

		osascript -e 'tell application "Keyboard Maestro Engine" to do script "R2C1 - EncryptMe - Set Button To Active Icon"'
	;;

	true)

		msg "Disabling..."

		encryptme-disable.sh

		osascript -e 'tell application "Keyboard Maestro Engine" to do script "R2C1 - EncryptMe - Set Button To Inactive Icon"'

	;;

	*)
		msg --sticky --title "$NAME: Status Unknown" "$STATUS"
	;;

esac

exit 0
#EOF
