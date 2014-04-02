#/bin/sh

BASEDIR=`dirname $0`
java -Xmx4096m -Xss65536k -cp ${BASEDIR}:/Applications/Alloy4.2.app/Contents/Resources/Java/alloy-dev.jar edu.mit.csail.sdg.alloy4whole.AlloyCLI $@
