for i in /opt/* ; do
	if [ -L "$i" ]; then
		if [ -d "$i/bin" ]; then
			if ! echo "$PATH" | grep -q "$i/bin" ; then
				PATH=$PATH:$i/bin
			fi
		fi
	fi
done
export PATH
