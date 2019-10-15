'UTILITIES FOR KSGE v0.1 20190922 ONLY 4 LINUX FOR NOW

dim totaladdr as integer
dim shared K1 as string*64
dim Kh as string*64
dim raddress(1 to 20) as string
dim usdprice as integer
dim randomizeprice as double
dim shared action as string

'********************************************************
'static parameters previously passed via command line
const C1 as string = "JENNIFER" 'model name wich should be equal to folder name
K1 = "XXXXXX" 'key used for encrypt media content and activation file
Kh = "YYYYYY" ' key used for temporary activation file (helpme)
usdprice = 1 'target price in USD (intended more or less because of volatility and randomization), please insert integer number example: 5
randomizeprice = 0.00009999 'randomize price in satoshi
raddress(1) = "bc1qarxefv6l3m7gmdaa03pgf4equr28y5flw9hgsp" 'address to check transaction for (where monetize)
raddress(2) = "bc1qndl39dxwfyje6te7fludy2vd8nsmmpjd56gdlr" 'address to check transaction for (where monetize)
raddress(3) = "bc1qwm5arqzdkgx6rvncdtdhrmg3sydupy5p3y98f5" 'address to check transaction for (where monetize)
raddress(4) = "bc1qn4w0lenk270jj36g8hn7t99d467rtqpqesqrn8" 'address to check transaction for (where monetize)
totaladdr = 4
const C3 as string = "mkv" 'clip file format
'print "K1:" 'debug
'print K1 'debug
'sleep 'debug
const C2 as string = "0" 'debug 0=no 1=yes
const C4 as string = "KISSBIT STRIP BLACKJACK" 'game name
dim C5 as string = Command(1)  'number of winning rows to strip opponent if no specified in command line
const C5bis as string = "2" 'numbero of standard rows (in case Commnand(1) = 0
const C6 as integer = 8 'number of stages allowed for demo

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

screen 21
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
print
print "0- quit"
input "-> " ; choice
print

if choice = 1 then
	'print "input video file format (example mkv)"
	'input "-> " ; extens
	'print
	shell "echo " + K1 + "| ./ccrypt/ccrypt -e -k - *." + C3
	print "DONE!"
	sleep
	print
end if

if choice = 2 then
	
	dim HW1 as string 
	dim cmd2 as string
	dim EML as string
	open pipe ("echo " + Kh + "| ./ccrypt/ccrypt -c -k - " + C1 + "-key.cpt") for Input as #3
		line input #3, EML
		line input #3, HW1
		print HW1
		print EML
	close #3
	print "ATTENTION: if key don't match, maybe the user is trying to do something bad"
	print "press enter to re-encryption"
	sleep
	
	shell "echo " + Kh + "| ./ccrypt/ccrypt -d -k - " + C1 + "-key.cpt"
	sleep 500,1
	shell "echo " + K1 + "| ./ccrypt/ccrypt -e -k - " + C1 + "-key"
	print "DONE!"
	sleep
	print
end if

if choice = 3 then
	'print "input video file format (example mkv)"
	'input "-> " ; extens
	'print
	shell "echo " + K1 + "| ./ccrypt/ccrypt -d -k - *." + C3 + ".cpt"
	print "DONE!"
	sleep
	print
end if

if choice = 4 then
	
	dim HW1 as string 
	dim cmd2 as string
	dim EML as string
	open pipe ("echo " + Kh + "| ./ccrypt/ccrypt -c -k - " + C1 + "-key.cpt") for Input as #3
		line input #3, EML
		line input #3, HW1
		print HW1
		print EML
	close #3
	print "ATTENTION: if key don't match, maybe the user is trying to do something bad"
	print "press enter to re-encryption for NO HW LIMIT DEPLOY"
	sleep
	
	'shell "echo " + Kh + "| ./ccrypt/ccrypt -d -k - " + C1 + "-key.cpt"
	'sleep 500,1
	kill C1 + "-key"
	kill C1 + "-key.cpt"
	sleep 100, 1
	open C1 + "-key" FOR OUTPUT AS #4
		print #4, EML
		'print #4, HW2
		print #4, K1
    CLOSE #4
	sleep 100, 1
	
	shell "echo " + K1 + "| ./ccrypt/ccrypt -e -k - " + C1 + "-key"
	print "DONE!"
	sleep
	print
end if

if choice = 5 then	
	dim HW1 as string 
	dim cmd2 as string
	dim EML as string
	open pipe ("echo " + K1 + "| ./ccrypt/ccrypt -c -k - " + C1 + "-key.cpt") for Input as #3
		line input #3, EML
		line input #3, HW1
		print HW1
		print EML
	close #3
	print "ATTENTION: if key don't match, maybe the user is trying to do something bad"
	sleep
end if

end
