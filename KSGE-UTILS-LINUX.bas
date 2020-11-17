'UTILITIES FOR KSGE v0.3 20201001
' v0.2 20191105
' v0.3 20201001

dim totaladdr as integer
dim shared K1 as string*64
dim Kh as string*64
dim raddress(1 to 20) as string
dim usdprice as integer
dim randomizeprice as double
dim shared action as string
dim shared shash as string
dim shared shashw as string

'********************************************************
'static parameters previously passed via command line
const C1 as string = "DEMO" 'model name wich should be equal to folder name
K1 = "6dhj3MFHQO348djfyg3KDFJ3ufjKFofwLgkj48jfLFL2euue" 'key used for encrypt media content and activation file
Kh = "jfheEEJDI£I3774646dKDKkfkfkfKFkfkeueufj3L£d39999" ' key used for temporary activation file (helpme)
shash = "bdeba239a6b92b6668ce63dbf8bc23e6  -" 'single hash for all clip *.cpt files
shashw = "BF85E9D2C105FE3976C89898568CAF47  -" 'single hash for all clip *.cpt files for wiindows platform
usdprice = 3 'target price in USD (intended more or less because of volatility and randomization), please insert integer number example: 5
randomizeprice = 0.00009999 'randomize price in satoshi
raddress(1) = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 'address to check transaction for (where monetize)
totaladdr = 1
const C3 as string = "mkv" 'clip file format
'print "K1:" 'debug
'print K1 'debug
'sleep 'debug
const C2 as string = "0" 'debug 0=no 1=yes
const C4 as string = "RED ROSE STRIP POKER" 'game name
dim C5 as string = Command(1)  'number of winning rows to strip opponent if no specified in command line
const C5bis as string = "2" 'numbero of standard rows (in case Commnand(1) = 0
const C6 as integer = 5 'number of stages allowed for demo

'********************************************************

'dim kchec as string
'input "please input key -> " ; kchec
'if kchec <> K1 then 
'	print "sorry wrong key"
'	sleep 3000
'	end
'end if


dim choice as integer
'dim extens as string

dim CC1 as string
	#IFDEF __FB_WIN32__
		CC1 = "..\" + C1
	#ELSE
		CC1 = "../" + C1
	#ENDIF

'screen 21
color 14,2
cls

print "KSGE ACTIVATOR/ENCRYPTER"
print
print "LAUNCH THIS PROGRAM INSIDE THE GAME FOLDER!"
print
print "1- video file encrypter"
print "2- activation file re-encryption"
print "3- video file decrypter"
print "4- activation file re-encryption 4 no hw limits"
print "5- look activated key for debug purpose"
print "6- generate single md5sum hash of encrypted *.cpt clips files (do it both on linux+windows)"
print
print "0- quit"
input "-> " ; choice
print

if choice = 1 then
	'print "input video file format (example mkv)"
	'input "-> " ; extens
	'print
	#IFDEF __FB_WIN32__
	shell "echo " + K1 + "| ccrypt-win\ccrypt.exe -e -k - *." + C3
	#ELSE
	shell "echo " + K1 + "| ./ccrypt/ccrypt -e -k - *." + C3
	#ENDIF
	print "DONE!"
	sleep
	print
end if

if choice = 2 then
	
	dim HW1 as string 
	dim cmd2 as string
	dim EML as string
	#IFDEF __FB_WIN32__
	open pipe ("echo " + Kh + "| ccrypt-win\ccrypt.exe -c -k - " + CC1 + "-key.cpt") for Input as #3
	#ELSE
	open pipe ("echo " + Kh + "| ./ccrypt/ccrypt -c -k - " + CC1 + "-key.cpt") for Input as #3
	#ENDIF
		line input #3, EML
		line input #3, HW1
		print HW1
		print EML
	close #3
	print "ATTENTION: if key don't match, maybe the user is trying to do something bad"
	print "press enter to re-encryption"
	sleep
	
	#IFDEF __FB_WIN32__
	shell "echo " + Kh + "| ccrypt-win\ccrypt.exe -d -k - " + CC1 + "-key.cpt"
	#ELSE
	shell "echo " + Kh + "| ./ccrypt/ccrypt -d -k - " + CC1 + "-key.cpt"
	#ENDIF
	sleep 500,1
	#IFDEF __FB_WIN32__
	shell "echo " + K1 + "| ccrypt-win\ccrypt.exe -e -k - " + CC1 + "-key"
	#ELSE
	shell "echo " + K1 + "| ./ccrypt/ccrypt -e -k - " + CC1 + "-key"
	#ENDIF
	print "DONE!"
	sleep
	print
end if

if choice = 3 then
	'print "input video file format (example mkv)"
	'input "-> " ; extens
	'print
	#IFDEF __FB_WIN32__
	shell "echo " + K1 + "| ccrypt-win\ccrypt.exe -d -k - *." + C3 + ".cpt"
	#ELSE
	shell "echo " + K1 + "| ./ccrypt/ccrypt -d -k - *." + C3 + ".cpt"
	#ENDIF
	print "DONE!"
	sleep
	print
end if

if choice = 4 then
	
	dim HW1 as string 
	dim cmd2 as string
	dim EML as string
	#IFDEF __FB_WIN32__
	open pipe ("echo " + Kh + "| ccrypt-win\ccrypt.exe -c -k - " + CC1 + "-key.cpt") for Input as #3
	#ELSE
	open pipe ("echo " + Kh + "| ./ccrypt/ccrypt -c -k - " + CC1 + "-key.cpt") for Input as #3
	#ENDIF
		line input #3, EML
		line input #3, HW1
		print HW1
		print EML
	close #3
	print "ATTENTION: if key don't match, maybe the user is trying to do something bad"
	print "press enter to re-encryption for NO HW LIMIT DEPLOY"
	sleep
	
	'shell "echo " + Kh + "| ./ccrypt/ccrypt -d -k - " + CC1 + "-key.cpt"
	'sleep 500,1
	kill CC1 + "-key"
	kill CC1 + "-key.cpt"
	sleep 100, 1
	open CC1 + "-key" FOR OUTPUT AS #4
		print #4, EML
		'print #4, HW2
		print #4, K1
    CLOSE #4
	sleep 100, 1
	
	#IFDEF __FB_WIN32__
	shell "echo " + K1 + "| ccrypt-win\ccrypt.exe -e -k - " + CC1 + "-key"
	#ELSE
	shell "echo " + K1 + "| ./ccrypt/ccrypt -e -k - " + CC1 + "-key"
	#ENDIF
	print "DONE!"
	sleep
	print
end if

if choice = 5 then	
	dim HW1 as string 
	dim cmd2 as string
	dim EML as string
	print "let's try to open key with K1...."
	#IFDEF __FB_WIN32__
	open pipe ("echo " + K1 + "| ccrypt-win\ccrypt.exe -c -k - " + CC1 + "-key.cpt") for Input as #3
	#ELSE
	open pipe ("echo " + K1 + "| ./ccrypt/ccrypt -c -k - " + CC1 + "-key.cpt") for Input as #3
	#ENDIF
		line input #3, EML
		line input #3, HW1
		print HW1
		print EML
		print
	close #3
	print "let's try to open key with Kh...."
	#IFDEF __FB_WIN32__
	open pipe ("echo " + Kh + "| ccrypt-win\ccrypt.exe -c -k - " + CC1 + "-key.cpt") for Input as #3
	#ELSE
	open pipe ("echo " + Kh + "| ./ccrypt/ccrypt -c -k - " + CC1 + "-key.cpt") for Input as #3
	#ENDIF
		line input #3, EML
		line input #3, HW1
		print HW1
		print EML
		print
	close #3
	print "ATTENTION: if key don't match, maybe the user is trying to do something bad"
	sleep
end if

if choice = 6 then
	#IFDEF __FB_WIN32__
	dim cmdshl as string
	cmdshl = "dir *.cpt /b /os | md5\md5.exe"
	Open Pipe cmdshl For Input As #1
	Dim As String ln
		Line Input #1, ln
		close #1
		print curdir
			Dim filename As String
			filename = Dir("*.cpt")
			Do While Len( filename ) > 0
				Print filename + " ";
				filename = Dir( )
			Loop
		print
		print "single hash for Windows platform is:"
		print ln
	#ELSE
	dim cmdshl as string
	cmdshl = "du --apparent-size -k *.cpt | md5sum"
	Open Pipe cmdshl For Input As #1
	Dim As String ln
		Line Input #1, ln
		close #1
		print curdir
			Dim filename As String
			filename = Dir("*.cpt")
			Do While Len( filename ) > 0
				Print filename + " ";
				filename = Dir( )
			Loop
		print
		print "single hash is for linux platform is:"
		print ln
	#ENDIF
	sleep
end if

end
