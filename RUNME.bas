'KSGE LAUNCHER
'LAUNCH BINARIES IN THE RIGHT WAY

chdir "core"

#IFDEF __FB_WIN32__
	print
#ELSE
	screen 17
	color 15,1
	cls
	print "IF YOU ARE USING LINUX, THIS GAME REQUIRES THE FOLLOWING PACKAGES: "
	print "VLC , XTERM AND WGET INSTALLED INTO THE SYSTEM"
	print
	print "PLEASE INSTALL WITH: sudo apt install xterm vlc wget"
	print
	print "this game is tested only on Debian 10 and Ubuntu 18.04"
	print
	print "press ENTER to continue"
	sleep
#ENDIF 

'shell "./ksec"

#IFDEF __FB_WIN32__
	shell "start ksge.exe 0"
#ELSE
	shell "xterm -fa 'Monospace' -fs 14 -e ./ksge 0"
#ENDIF

end

