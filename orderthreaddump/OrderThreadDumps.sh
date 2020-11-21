#!/bin/sh

set -x
cat weblogic.log \
	| grep -v '\- locked' \
	| grep -v '\- waiting ' \
	| grep -v 'at pkgs\.' \
	| grep -v 'TimerClientPool' \
	| grep -v 'weblogic.socket.Muxer' \
	| grep -v 'weblogic.security.SpinnerRandomBitsSource' \
	| grep -v 'weblogic.t3.srvr.T3Srvr' \
	| grep -v 'weblogic.time.common.internal' \
	| grep -v 'weblogic.t3.srvr.CoreHealthMonitorThread' \
	| grep -v 'JmsDispatcher' \
	| grep -v 'TimerClientPool' \
	| grep -v 'weblogic.admin' \
	| grep -v 'Daemon' \
	| grep -v 'TaskHandler' \
	| grep -v 'DGCClient' \
	| grep -v 'ListenThread' \
	| grep -v 'at com.octetstring' \
	| grep -v '\.\_\_WL\_'   \
	| grep -v '\_\_WebLogic\_'   \
	| grep -v '\_ELOImpl\.' \
	| grep -v '\_EOImpl\.' \
	| grep -v 'at oracle\.' \
	| grep -v 'at java' \
	| grep -v 'at sun\.' \
	| grep -v 'at weblogic' \
	| grep -v 'at com.bea' \
	| grep -v 'at org\.' \
	| sed 's/(.*)//' \
	| \
    perl OrderThreadDumps.pl -f > OrderedThreadDump.txt
