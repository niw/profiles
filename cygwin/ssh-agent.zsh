AGENT_STATUS_FILE=/var/run/${AGENT_COMMAND}.status
AGENT_COMMAND=ssh-agent
AGENT_ADD_CMD=ssh-add
SSH_PRIVATE_KEY=~/.ssh/id_dsa
MESSAGE_COLOR="$fg[yellow]"

if [ -f "${AGENT_STATUS_FILE}" ]; then
	eval `cat "${AGENT_STATUS_FILE}"` > /dev/null
	if [ -d /proc/${SSH_AGENT_PID} ]; then
		if [ "`cat /proc/${SSH_AGENT_PID}/exename`" = "`which ${AGENT_COMMAND}`.exe" ]; then
			echo "${MESSAGE_COLOR}The ${AGENT_COMMAND} is already running (pid: ${SSH_AGENT_PID})$reset_color"
			return
		fi
	fi
	rm "${AGENT_STATUS_FILE}"
	rm -r `echo $SSH_AUTH_SOCK | sed -e 's/[^/]*$//g'`
	unset SSH_AGENT_PID
	unset SSH_AUTH_SOCK
	export SSH_AGENT_PID SSH_AUTH_SOCK
	echo "${MESSAGE_COLOR}We detect and sweep ${AGENT_COMMAND} status file$reset_color"
fi
${AGENT_COMMAND} > ${AGENT_STATUS_FILE}
eval `cat "${AGENT_STATUS_FILE}"` > /dev/null
echo "${MESSAGE_COLOR}Now ${AGENT_COMMAND} is running (pid: ${SSH_AGENT_PID}), and add the private key...$reset_color"
${AGENT_ADD_CMD} "${SSH_PRIVATE_KEY}"

# vim:ts=4:sw=4:noexpandtab:ft=zsh
