if [ -x /usr/libexec/java_home ]; then
  export JAVA_HOME=`/usr/libexec/java_home -v 1.6`
fi

export JAVA_TOOLS_OPTS="-Dfile.encoding=UTF8"
