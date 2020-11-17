' STILL TO BE REWRITTEN

' KSPC - K.I.S.S. BITCOIN PAYMENT CHECKER VERSION 1.4 20190922
' bitcoin payment checker for KISS STRIP GAME ENGINE (KSGE) based on price and address semi-randomization
' it will ask to send a semi-random-range amount of bitcoin to an address selected randomly form a given group of addresses
' it will ask for the transaction ID and:
' search if for the in-code-gived btc address exists this transaction with the in-code-gived amount in satoshi. it will check about (more or less) last 24 transactions on the gived address
' if payment ok (found correct amount in the correct wallet) it will ask for an email address and write the encrypted name-key file inside the opponent folder
' if transaction number = helpme ;  an activation file is written with a different encryption key, so it can be sended to the game provider for manual activation
'
' this application, wich of course cannot be perfect, tries to resolve all the privacy issues involved when using a 3rd party payment gateway
' no personal data is sended anywhere, of course the btc blockchain explorer may track something (for example ip address), but this cannot easily avoided for example using a vpn

#include "string.bi"

dim address as string
dim raddress(1 to 20) as string
dim totaladdr as integer
dim K1 as string*64
dim Kh as string*64
dim shared amount as string*10
dim shared btcto1usdstrl as string*8
dim transaction as string
dim btcto1usdcmd as string
dim btcto1usdstr as string
dim btcto1usd as double
dim usdprice as integer
dim randomizeprice as double
dim satoshiprice as double
dim eml as string
dim paychk as integer 'if paycheck = 2 then paycheck is ok, otherwise no
paychk = 0

#IFDEF __FB_WIN32__
const decryptexename = "ccrypt-win\ccrypt.exe "
#ELSE
const decryptexename = "ccrypt/ccrypt "
#ENDIF

dim shared blockexplorer as string
dim shared curlreply as string
dim i as integer
dim value as string'
dim target as string
dim utime as string
dim shared txlenghtlimited as string * 32768
' string * 32768 is string lenght... 32768 will check for about 24 last transactions for the gived address
randomize timer

Function rnd_range (first As double, last As double) As double 
    Function = Rnd * (last - first) + first
End Function

sub chkbin 'chk if the bin(s) are genuine
	
	#IFDEF __FB_WIN32__
		dim cmdshl as string
		cmdshl = ("md5\md5.exe wget-win\wget.exe")
		Open Pipe cmdshl For Input As #1
		Dim As String ln
		Do Until EOF(1)
			Line Input #1, ln
			if ln <> "838C3982C8F34C3BD7ABAE429C4B3380  wget-win\wget.exe" then
				print ln
				print "ERROR: WRONG WGET CHECKSUM!"
				sleep 3000,1
				end
			end if
		Loop
		Close #1
	#ENDIF
end sub

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

'print "K1: "; K1 'debug
'sleep 'debug

address = raddress (rnd_range(1, totaladdr))

const hlpusr as string = "helpme"

'address = raddress (7) '************************ debug

#IFDEF __FB_WIN32__
btcto1usdcmd = "wget-win\wget.exe -qO- ""https://blockchain.info/tobtc?currency=USD&value=1"""
blockexplorer = "wget-win\wget.exe -qO- https://chain.api.btc.com/v3/address/" + address + "/tx"
#ELSE
btcto1usdcmd = "wget -qO- ""https://blockchain.info/tobtc?currency=USD&value=1"""
blockexplorer = "wget -qO- https://chain.api.btc.com/v3/address/" + address + "/tx"
#ENDIF

sub transread
	open pipe blockexplorer for input as #1
		dim as string ln
		do until eof(1)
			line input #1, ln
			'print ln 'debug
			curlreply=curlreply+ln
			'*** check if TIME TERM exceded
			'***
		loop
	close #1
	txlenghtlimited = curlreply
	'print txlenghtlimited 'debug
end sub

color 15,1
cls
print ".....PLEASE WAIT....."
chkbin

open pipe btcto1usdcmd for input as #2
	dim as string ln2
	do until eof(2)
		line input #2, ln2
		btcto1usdstr=btcto1usdstr+ln2
	loop
close #2



btcto1usd = val(btcto1usdstr)

if btcto1usd < 0.00011111 then
	btcto1usd = 0.00011111 + (rnd_range(0.00000000, randomizeprice))
	'print "BTC value < 11111 !"
	print "......PLEASE WAIT....."
	sleep 2000,1
	'sleep 'debug
end if
'print "btcto1usdstr = " ; btcto1usdstr 'debug
'print "btcto1usd = " ; btcto1usd 'debug
'sleep 'debug
'btcto1usdstrl = FORMAT(btcto1usd, "00000000") '1 dollar btc value in satoshi with no comma


'print "btctoqusdstr = ", btcto1usdstr 'debug
'sleep 'debug



'print "bittousdstrl (current BTC price in satoshi) = ", btcto1usdstrl 'debug
'sleep 2000  'debug

'print "1 USD = " , btcto1usd ; " BTC" 'debug
'sleep 'debug

'print "randomize test: " , str (rnd_range(0.00000000, randomizeprice)) 'debug
satoshiprice = (btcto1usd * usdprice) + (rnd_range(0.00000000, randomizeprice))

transread


'print "satoshiprice: " , satoshiprice 'debug
'sleep 'debug
dim stramount as string*8 'amount in satoshi, only satoshi, no comma
stramount = str(satoshiprice)
'amount = FORMAT(satoshiprice, "00000000") 'amount in satoshi to search for
amount = str(satoshiprice) 
'print "right amount: ", amount 'debug
'sleep  'debug
do
	
	i = instr(txlenghtlimited, amount)
	if i > 0 then
		'print "found duplicated value: " & i 'debug
		'sleep 1000 'debug
		satoshiprice = satoshiprice + 0.00000001
		'amount = FORMAT(satoshiprice, "00000000") 'amount in satoshi to search for
		amount = str(satoshiprice) 
		'print satoshiprice 'debug
		'print amount 'debug
		'sleep 1000'debug
	else
		exit do
	end if	
loop 


'print "randomized price in Satoshi: " ; satoshiprice 'debug
'sleep 'debug

wait4trans:
color 15,1
cls

print "******************************"
print "**K.I.S.S. STRIP GAME ENGINE**"
print "******************************"
print "with: " ; C1
print
print "IF YOU WANT TO CONTINUE UNDRESSING THE OPPONENT" 
print "PLEASE SEND " ; amount ; " BITCOIN TO THIS ADDRESS:"
print
print address
print 
print "ONCE DONE PLEASE WAIT SOME MINUTES,"
print "THEN PASTE THE TRANSACTION ID IN THIS WINDOW AND PRESS ENTER."
print

#IFDEF __FB_WIN32__
print "TO COPY/PASTE FROM THIS WINDOW USE CTRL+C (COPY) AND CTRL+V (PASTE)"
#ELSE
print "TO COPY/PASTE FROM THIS WINDOW USE THE MIDDLE MOUSE BUTTON"
#ENDIF

print
print "please once you send bitcon, don't close this window,"
print "or you may need to send again a different amount of bitcoin."
print "thank you for supporting this game and for your patience."
print

print "PASTE THE TRANSACTION ID: --> " ;
transaction = ""
Dim As Long kk
Do
    kk = GetKey
    Print chr (kk);
    if kk <> 13 then
		transaction = transaction + chr (kk)
	end if
Loop Until kk = 13 'keep reading key pressend until enter is pressed
'print transaction 'debug
print "PLEASE WAIT....."
sleep 5000,1

'if transaction = hlpusr then
'rem**********************************************************************************
'end if


transread 


'search for transaction (but not care for now...)
i = instr(txlenghtlimited, transaction)
if i > 0 then
	'paychk = paychk + 1
    print "OK - found right transaction"
end if

'clean amount removing 0.0s (zeros on left) ; new variable amountnoz will be used
Dim idx As Integer
dim idx2 as integer
idx2 = 0
dim amountnoz as string
idx = instr(amount, Any "0.")
Do While idx > 0 'if not found loop will be skipped
	idx2 = idx2 + 1
    idx = idx + 1
    idx = InStr(idx, amount, Any "0.")
    
Loop
' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! amountnoz must be checked if even or odd to avoid zeros on end!
amountnoz = Mid(amount, (idx2 + 1))

' ************************************************************************************************* DBG
'amountnoz = "65100" ' debug
' ************************************************************************************************* DBG
'&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

'print "amountnoz = " ; amountnoz 'debug
'sleep 3000 'debug





'search for transaction value
i = instr(txlenghtlimited, amountnoz)
if i > 0 then
	paychk = paychk + 1
    print "OK - found right value"
end if

'if paychk = 2 then
if paychk = 1 or transaction = hlpusr then
	'GetKey 'clear the keyboard buffer
	line input "PLEASE ENTER YOUR E-MAIL ADDRESS: "; eml
	
	dim HW1 as string 
	'dim HW2 as string
	dim cmd2 as string
	Dim As String lin
	
	#IFDEF __FB_WIN32__
		Open Pipe "getmac /fo csv /nh" For Input As #3
	#ELSE
		Open Pipe "ip addr | grep ether" For Input As #3
	#ENDIF
	
	'Do Until EOF(2)
		Line Input #3, HW1
		'print lin 'debug
		'HW1 = HW1 + lin
	'Loop
	Close #3
	
	sleep 100, 1
	
	'Open Pipe "host name" For Input As #5
	'Do Until EOF(2)
	'	Line Input #2, lin
		'print lin 'debug
	'	HW2 = HW2 + lin
	'Loop
	'Close #5
	
	kill C1 + "-key"
	kill C1 + "-key.cpt"
	sleep 100, 1
	open C1 + "-key" FOR OUTPUT AS #4
		print #4, eml
		'print #4, HW2
		print #4, HW1
    CLOSE #4
	sleep 100, 1
	
	dim cmdline as string
	Dim result As Integer
	
	if transaction = hlpusr then
		cmdline = "echo " + Kh + "| " + decryptexename + " -e -k - " + C1 + "-key"
		result = Shell (cmdline) 
		If result = -1 Then
			Print "Error creating key"
		end if
	color 15,1
	'cls
	print
	print
	print
	print
	print
	print "KEY FILE FOR MANUAL ACTIVATION PRODUCED"
	print "PLEASE SEND " + C1 + "-key.cpt FILE TO GAME PROVIDER MAIL AS ATTACHMENT"
	print "THE FILE IS LOCATED IN THE GAME FOLDER"
	print "PLEASE WRITE ALSO THE BITCOIN TRANSACTION ID IN THE MAIL BODY"
	print "THEN WAIT FOR INSTRUCTIONS; THANK YOU IN ADVICE"
	print "PRESS ENTER TO CONTINUE"
	sleep 
	GetKey 'clear the keyboard buffer
	endif
	
	if paychk = 1 then
		cmdline = "echo " + K1 + "| " + decryptexename + " -e -k - " + C1 + "-key"
		result = Shell (cmdline) 
		If result = -1 Then
			Print "Error creating key"
		end if
	cls
	color 15,1
	print
	print
	print "THANK YOU! ENJOY THE GAME!"
	print "PRESS ENTER TO CONTINUE"
	sleep 
	GetKey 'clear the keyboard buffer
	endif
	
	
	
else
	color 15,1
	cls
	print
	print
	print "SORRY TRANSACTION NOT FOUND AND/OR AMOUNT DON'T MATCH"
	print "PLEASE WAIT SOME MINUTES AND TRY AGAIN, DON'T CLOSE THIS WINDOW"
	print "IF PROBLEM PERSISTS AFTER 1 HOUR OR MORE PLEASE CONTACT THE GAME PROVIDER"
	print "PRESS ENTER TO TRY AGAIN"
	sleep 
	GetKey 'clear the keyboard buffer
	goto wait4trans
end if

