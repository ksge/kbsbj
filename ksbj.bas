' K.I.S.S. STRIP BLACK JACK VERSION 3.3 20190922
'v1.0 first full working version
'v1.1 small bugfixes
'v2.0 first version working on memory (linux only)
'v3.0 if action=qui quit game
'v3.1 bugfixes + tested on Ubuntu 18.04.3
'v3.2 bugfixes + tested on win10 1903
'v3.3 bugfixes
'v3.4 fixed high cpu usage + ability to choose winning rows by hitting number in welcome screen
' A STRIP BLAKCJACK GAME BUILD WITH FREEBASIC AND BASED ON KSGE (KISS STRIP GAME ENGINE) 
' COMPILE WITH FREEBASIC COMPILER (FBC) TESTET WITH VERSION 1.7.1 ON LINUX (DEBIAN 10 + UBUNTU 18.04) OR WINDOWS 10
' compile with -s gui switch reccomended
' on linux, following packages are needed to compile, please install them:
' sudo apt install -y gcc libncurses-dev libgpm-dev libx11-dev libxext-dev libxpm-dev libxrandr-dev libxrender-dev libgl1-mesa-dev libffi-dev libtinfo5
' AFTER COMPILED RUN THE BINARY WITH THE CORRECT PARAMETERS: KSBJ row number    game name    model name/folder   debug(0=no 1=yes)
' example; ksbj 2 "KISS BLACKJACK" "marylin" 0 
print "KSBJ version 3.4 20200219"


'-------------------------------------------------
'Card Class
'-------------------------------------------------
Enum Suits
	SPADES = 1
	DIAMONDS
	HEARTS
	CLUBS
End Enum

Enum Faces
	ACE = 1
	JACK = 11
	QUEEN
	KING
End Enum

Enum BOOL
	FALSE = 0
	TRUE = -1
End Enum

Enum GameState
	NewGame = 0
	PlayerTurn
	DealerTurn
	JudgeScore
	GameOver
End Enum

Type Card
	suit As Integer
	face As Integer
	isFaceDown As BOOL = FALSE
End Type

Type Deck Extends Object
	Private:
		'member variables
		m_Cards(Any) As Card
		m_NumCards As Integer
	
	Public:
		'Constructors and Destuctors
		Declare Constructor()
		Declare Destructor()
		
		'Methods
		Declare Sub Shuffle()
		Declare Function Draw() As Card
		Declare Sub Add(crd As Card)
		Declare Function GetNumOfCards() As Integer
		Declare Function LookAtCard(index As Integer) As Card
		Declare Sub SetFaceDown(index As Integer, isFaceDown As BOOL)
End Type

Constructor Deck()

End Constructor

Destructor Deck()
	'Nothing yet
End Destructor

Sub Deck.Shuffle()
	Dim tempCard1 As Card
	Dim tempCard2 As Card
	Dim rndNum As Integer
	
	'Shuffles the deck
	If this.m_NumCards <> 0 Then
		For i As Integer = 1 To this.m_NumCards
			tempCard1 = this.m_Cards(i)	
			rndNum = Int(Rnd * (this.m_NumCards - 1)) + 1
			tempCard2 = this.m_Cards(rndNum)
			this.m_Cards(i) = tempCard2
			this.m_Cards(rndNum) = tempCard1
		Next
	EndIf
End Sub

Function Deck.Draw() As Card
	'Draw a card out of the deck, copy it, and pass it out to the system.
	Dim tempCard As Card
	If this.m_NumCards <> 0 Then
		tempCard = this.m_Cards(this.m_NumCards)
		this.m_NumCards -= 1
		ReDim Preserve this.m_Cards(this.m_NumCards)
	EndIf
	Return tempCard
End Function

Sub Deck.Add(crd As Card)
	'Add a card back into the deck
	this.m_NumCards += 1
	ReDim Preserve this.m_Cards(this.m_NumCards)
	this.m_Cards(this.m_NumCards) = crd
End Sub

Function Deck.GetNumOfCards() As Integer
	Return this.m_NumCards
End Function

Function Deck.LookAtCard(index As Integer) As Card
	Return this.m_Cards(index)
End Function

Sub Deck.SetFaceDown(index As Integer, isFaceDown As BOOL)
	this.m_Cards(index).isFaceDown = isFaceDown
End Sub

'-------------------------------------------------
'Start Test Program
'-------------------------------------------------
'chdir Command(3)
'-------------------------------------------------
'Includes
'-------------------------------------------------
#Include Once "fbgfx.bi"

'-------------------------------------------------
'Initialization
'-------------------------------------------------
Randomize Timer

ScreenRes 320, 200, 24,,&h20
width 40,12



Dim Shared suitBMP(1 To 4) As FB.IMAGE Ptr
For i As Integer = 1 To 4
	suitBMP(i) = ImageCreate(16,16)
Next

BLoad "images/heart.bmp", suitBMP(Suits.HEARTS)
BLoad "images/diamond.bmp", suitBMP(Suits.DIAMONDS)
BLoad "images/club.bmp", suitBMP(Suits.CLUBS)
BLoad "images/spade.bmp", suitBMP(Suits.SPADES)

Color RGB (0, 0, 0), RGB (210, 180, 140)
Cls

Dim DrawPile As Deck
Dim Dealer As Deck
Dim Player As Deck
Dim tempCard As Card

Dim shared Menu As String
dim shared wininarow as integer 'xxx victories in a raw.... every nrow wins in a raw opponents remove something...
dim shared losinarow as integer 'xxx loses in a raw... every nrow wins in a row player remove something...
dim shared wrow as integer 'xxx victories in a raw.... every nrow wins in a raw opponents remove something...
dim shared lrow as integer 'xxx loses in a raw... every nrow wins in a row player remove something...
dim shared action as string 'xxx variable used to comunicate witch clip queue based on game events...
dim shared checkdo as string
dim shared nrow as integer 'param that indicates number of win rows needed to remove something
dim shared wfile as string

nrow = val (Command(1)) ' pass param to integer

Const LEFTBUTTON   = 1
Const MIDDLEBUTTON = 4   ' UNUSED
Const RIGHTBUTTON  = 2   ' UNUSED
Const SHOWMOUSE    = 1
Const HIDEMOUSE    = 0

Dim shared CurrentX     As Integer
Dim shared CurrentY     As Integer
Dim shared MouseButtons As Integer
Dim shared CanExit      As Integer

' let's see if we are on linux or windows
#IFDEF __FB_WIN32__
   CONST OS = "windows"
#ELSE
   CONST OS = "linux"
#ENDIF
print "KSBJ FOR: " ; OS
'sleep 1000


#IFDEF __FB_WIN32__
	'mkdir "%tmp%\.ksge" 
	wfile = ".ksge\action" + Command(3)
#ELSE
	'mkdir "/dev/shm/.ksge" 
	wfile = "/dev/shm/.ksge/action" + Command(3)
#ENDIF

'-------------------------------------------------
'Subroutines and Functions
'-------------------------------------------------
sub dbgcons (msg as string) 'debug to console
	if Command(4) = "1" then
		open cons for output as #1
		print #1,msg
		close #1
	end if
end sub

Function rd_range (frst As Double, lst As Double) As Double 'random number inrage to choose if ris or act during 1stage games
    Function = Rnd * (lst - frst) + frst
End Function

sub queueaction(act as string)
	dim rdrange as integer
	'checkdo = ""
	Menu = ""
	dbgcons "in queueaction"
	dbgcons "wininarow: "
	dbgcons str (wininarow)
	open wfile FOR INPUT AS #6 LEN = 3
    input #6, checkdo
    CLOSE #6
	
	if checkdo = "end" then 
		dbgcons "THE END!"
		cls
		Draw String (0,30), "....I knew it...."
		Draw String (0,50), "press (ESC) to Quit"
		sleep
		' send quit do video thread
		act = "qui"
		open wfile FOR OUTPUT AS #7 LEN = 3
		print #7, act
		CLOSE #7
		dbgcons "writed act:"
		dbgcons act
		end
	end if
	
	
	if checkdo = "qui" then 
		dbgcons "QUIT GAME!"
		sleep 2000,1
		'cls
		'Draw String (0,30), "....I knew it...."
		'Draw String (0,50), "press (ESC) to Quit"
		'sleep
		' send quit do video thread
		'act = "qui"
		'open wfile FOR OUTPUT AS #7 LEN = 3
		'print #7, act
		'CLOSE #7
		'dbgcons "writed act:"
		'dbgcons act
		end
	end if
	
	
   redo: 'redo cicle if needed (example after los off)
   open wfile FOR OUTPUT AS #7 LEN = 3
   print #7, act
   CLOSE #7
   dbgcons "writed act:"
   dbgcons act
   
   if act = "ris" then
	goto endqueueaction
   end if
   
   if act = "los" or act = "win" or act = "off" then
    checkdo = act
    do 
	 sleep 1000,1
	 open wfile FOR INPUT AS #6 LEN = 3
     input #6, checkdo
     CLOSE #6
     dbgcons "waiting for act done"
    loop until checkdo <> act
    end if
    
    if act = "off" then 
		sleep 10000,1
	end if
	
    
    if act = "los" and wininarow >= nrow then
		dbgcons "in act > 2"
		act = "off"
		goto redo
	elseif act = "los" and wininarow >= (nrow-1) then
		dbgcons "in act > 1"
		act = "ris"
		goto redo
	elseif nrow = 1 then
		dbgcons "in act else (risk 1 stage)"
		rdrange = rd_range(1, 3)
		dbgcons str (rdrange)
		select case rdrange
		case 1
			act = "ris"
			'goto redo ******************
		case 3
			act = "ris"
			goto redo
		end select
		
	end if
    
    if checkdo = "end" then 
		dbgcons "THE END!"
		cls
		Draw String (0,30), "....I knew it...."
		Draw String (0,50), "this is so embarassing.."
		Draw String (0,70), "press (ESC) to Quit"
		sleep
		Draw String (0,80), "press (ESC) again to Quit"
		sleep 2000,1
		sleep
		' send quit to video thread
		act = "qui"
		open wfile FOR OUTPUT AS #7 LEN = 3
		print #7, act
		CLOSE #7
		dbgcons "writed act:"
		dbgcons act
		end
	end if
	
   endqueueaction:
   dbgcons "queueaction finished"
end sub


Sub DrawCard(x As Integer, y As Integer, crd As Card)
	Line (x, y)-(x + 33, y + 49), RGB(0, 0, 0),b
	Line (x + 1, y + 1)-(x + 32,y + 48), RGB(255, 255, 255),bf
	If Not(crd.isFaceDown) Then
		Put(x + 2, y + 2), suitBMP(crd.suit), Trans
		Select Case crd.face
			Case Faces.ACE
				Draw String(x + 14,y + 21), "A"
			Case Faces.JACK
				Draw String(x + 14,y + 21), "J"
			Case Faces.QUEEN
				Draw String(x + 14,y + 21), "Q"
			Case Faces.KING
				Draw String(x + 14,y + 21), "K"
			Case Else
				Draw String(x + 14,y + 21), Str(crd.face)
		End Select
	Else
		Line (x + 3, y + 3)-(x + 30,y + 46), RGB(0, 0, 255),bf
	EndIf
	
End Sub

Sub DrawDeck(x As Integer, y As Integer, dck As Deck)
	Dim num As Integer = dck.GetNumOfCards()
	
	For i As Integer = 0 To num -1
		DrawCard(x + (35 * i), y, dck.LookAtCard(i+1))
	Next
End Sub

Function TotalDeck(dck As Deck) As Integer
	Dim total As Integer
	
	For i As Integer = 1 To dck.GetNumOfCards()
		Select Case dck.LookAtCard(i).face
			Case Faces.JACK, Faces.QUEEN, Faces.KING
				total += 10
			Case 2 To 10
				total += dck.LookAtCard(i).face
			Case Faces.ACE
				If total > 10 Then
					total += 1
				Else
					total += 11
				EndIf
		End Select
	Next
	
	Return total
End Function

sub catchmouse
dim clicked as string
clicked = ""
Do
   GetMouse CurrentX, CurrentY, , MouseButtons
   'dbgcons str(CurrentX)
   'dbgcons str(CurrentY)
   If MouseButtons And LEFTBUTTON Then
      If CurrentX <= 41 and CurrentY >= 37 and CurrentY <= 149 Then
            'dbgcons "HIT selected"
            clicked = "H"
         End If
      End If
Loop While clicked = ""
End sub
'-------------------------------------------------
'Start of game code
'-------------------------------------------------

For i As Integer = 1 To 4
	For j As Integer = 1 To 13
		tempCard.suit = i
		tempCard.face = j
		DrawPile.Add(tempCard)
	Next
Next


Dim key As String
Dim totalDealer As Integer
Dim totalPlayer As Integer
Dim state As GameState

Dim Message As String
dim whattodo as string


' welcome screen
dbgcons "LET'S START!"
dbgcons "parameters:"
dbgcons Command(0) 
dbgcons Command(1) 'number of win row to off
dbgcons Command(2) 'game name example: super blackjack with hawai
dbgcons Command(3) 'model name (and also dir name)
dbgcons Command(4) 'filler

cls
print Command(2) 'game name
print "with: " & Command(3) 'model name
print "every " & str(nrow) & " wins in a row" 
print "opponent will remove something"
print
print "- LEFT MOUSE BUTTON to play/hit"
print "- RIGHT MOUSE BUTTON to stay"
print "- ESC to exit game"
print "you can also use keyboard:"
PRINT "P=play H=hit S=stay"
print "LEFT MOUSE BUTTON OR HIT P TO START"
do
	sleep 99 '3.4
	key=inkey
	GetMouse CurrentX, CurrentY, , MouseButtons
loop until key = "P" or key = "p" or key = "1" or key= "2" or key= "3" or key = "4" or key = "5" or MouseButtons = LEFTBUTTON
'sleep 99,1 '3.4

select case key
	case "1"
	nrow = 1
	case "2"
	nrow = 2
	case "3"
	nrow = 3
	case "4"
	nrow = 4
	case "5"
	nrow = 5
end select


Do 
	'dbgcons "start main do"
	Print #1, state
	If state <> GameState.NewGame And state <> GameState.GameOver Then
		If totalPlayer > 21 Then
			Menu = ""
			Dealer.SetFaceDown(1,FALSE)
			state = GameState.GameOver
			Message = "You Busted! I Win!"
			wininarow = 0
			losinarow = losinarow + 1
			queueaction ("win")
			Menu = "(P)lay again (ESC) to Quit"
		EndIf
		
		If totalDealer > 21 Then
			Dealer.SetFaceDown(1,FALSE)
			state = GameState.GameOver
			Message = "I Busted.. You Win.."
			Menu = ""
			wininarow = wininarow + 1
			losinarow = 0
			queueaction ("los")
			Menu = "(P)lay again (ESC) to Quit"
		EndIf
		
		'Five Cards?
		If Dealer.GetNumOfCards() = 5 And totalDealer <= 21 Then
			Dealer.SetFaceDown(1,FALSE)
			state = GameState.GameOver
			Message = "I have five cards! I Win!"
			wininarow = 0
			losinarow = losinarow + 1
			queueaction ("win")
			Menu = "(P)lay again (ESC) to Quit"
		EndIf
		
		If Player.GetNumOfCards() = 5 And totalPlayer <= 21 Then
			Dealer.SetFaceDown(1,FALSE)
			state = GameState.GameOver
			Message = "You have five cards.. You Win.."
			wininarow = wininarow + 1
			losinarow = 0
			queueaction ("los")
			Menu = "(P)lay again (ESC) to Quit"
		EndIf
		
		'Black Jack and Ace?
		If Player.GetNumOfCards() = 2 Then
			If Player.LookAtCard(1).suit = Suits.CLUBS OrElse Player.LookAtCard(1).suit = Suits.SPADES Then
				If Player.LookAtCard(1).face = Faces.JACK Then
					If Player.LookAtCard(2).face = Faces.ACE Then
						Dealer.SetFaceDown(1,FALSE)
						state = GameState.GameOver
						Message = "You have Black Jack..You Win.."
						wininarow = wininarow + 1
						losinarow = 0
						queueaction ("los")
						Menu = "(P)lay again (ESC) to Quit"
					EndIf
				EndIf
			EndIf
			If Player.LookAtCard(2).suit = Suits.CLUBS OrElse Player.LookAtCard(2).suit = Suits.SPADES Then
				If Player.LookAtCard(2).face = Faces.JACK Then
					If Player.LookAtCard(1).face = Faces.ACE Then
						Dealer.SetFaceDown(1,FALSE)
						state = GameState.GameOver
						Message = "You have Black Jack..You Win.."
						wininarow = wininarow + 1
						losinarow = 0
						queueaction ("los")
						Menu = "(P)lay again (ESC) to Quit"
					EndIf
				EndIf
			EndIf
		EndIf
		
		If Dealer.GetNumOfCards() = 2 Then
			If Dealer.LookAtCard(1).suit = Suits.CLUBS OrElse Dealer.LookAtCard(1).suit = Suits.SPADES Then
				If Dealer.LookAtCard(1).face = Faces.JACK Then
					If Dealer.LookAtCard(2).face = Faces.ACE Then
						Dealer.SetFaceDown(1,FALSE)
						state = GameState.GameOver
						Message = "I have Black Jack! I Win!"
						wininarow = 0
						losinarow = losinarow + 1
						queueaction ("win")
						Menu = "(P)lay again (ESC) to Quit"
					EndIf
				EndIf
			EndIf
			If Dealer.LookAtCard(2).suit = Suits.CLUBS OrElse Dealer.LookAtCard(2).suit = Suits.SPADES Then
				If Dealer.LookAtCard(2).face = Faces.JACK Then
					If Dealer.LookAtCard(1).face = Faces.ACE Then
						Dealer.SetFaceDown(1,FALSE)
						state = GameState.GameOver
						Message = "I have Black Jack! I Win!"
						wininarow = 0
						losinarow = losinarow + 1
						queueaction ("win")
						Menu = "(P)lay again (ESC) to Quit"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	'New game starting?
	Select Case state
		Case GameState.NewGame
			'Cards in the dealer's hand?
			If Dealer.GetNumOfCards() <> 0 Then
				'Empty it
				While Dealer.GetNumOfCards() <> 0
					DrawPile.Add(Dealer.Draw())
				Wend
			EndIf
			
			'Cards in the player's hand?
			If Player.GetNumOfCards() <> 0 Then
				'Empty it
				While Player.GetNumOfCards() <> 0
					DrawPile.Add(Player.Draw())
				Wend
			EndIf
			
			'Shuffle draw deck
			DrawPile.Shuffle()
			
			'Draw cards
			Dealer.Add(DrawPile.Draw())
			Dealer.SetFaceDown(1, TRUE)
			Dealer.Add(DrawPile.Draw())
			
			Player.Add(DrawPile.Draw())
			Player.Add(DrawPile.Draw())
			
			totalDealer = TotalDeck(Dealer)
			totalPlayer = TotalDeck(Player)
		
			'Menu = "(H)it (S)tay (ESC) to Quit"
			Message = ""
			state = GameState.PlayerTurn
			
		Case GameState.PlayerTurn
			Menu = "(H)it (S)tay (ESC) to Quit"
			'Hit
			'catchmouse
			If key = "H" Or key = "h" Then
				Player.Add(DrawPile.Draw())
			Menu = ""	
			'Stay
			ElseIf key = "S" Or key = "s" Then
				state = GameState.DealerTurn
				Menu = ""
			EndIf
		Case GameState.DealerTurn
			Menu = ""
			Sleep 10,1
			If totalDealer < 16 Then
				Dealer.Add(DrawPile.Draw())
			Else
				state = GameState.JudgeScore
			EndIf
		Case GameState.JudgeScore
			Menu = ""
			If totalDealer >= totalPlayer Then
				Message =  "I Win!"
				wininarow = 0
				losinarow = losinarow + 1
				queueaction ("win")
			Else
				Message = "You Win.."
				wininarow = wininarow + 1
				losinarow = 0
				queueaction ("los")
			EndIf
			state = GameState.GameOver
			Dealer.SetFaceDown(1,FALSE)
			Menu = "(P)lay again (ESC) to Quit"
		Case GameState.GameOver
		
		'Mouse handle
		If MouseButtons = LEFTBUTTON then 
			key = "P"
			sleep 99,1
		end if
		
			If key = "P" Or key = "p" Then
				if losinarow >= nrow then losinarow = 0
				if wininarow >= nrow then wininarow = 0
				state = GameState.NewGame
			EndIf
	End Select
	
	totalDealer = TotalDeck(Dealer)
	totalPlayer = TotalDeck(Player)
	
		
	ScreenLock
	Cls

	Draw String (0,00), "Me: "
	Draw String (0,20), "row: " & Str(losinarow) & "/" & str(nrow) 'xxx draw loses in a raw status
	Draw String (0,70), "You:"
	Draw String (0,90), "row: " & Str(wininarow) & "/" & str(nrow) 'xxx draw victories in a raw status
	
	If state = GameState.GameOver Then
		if losinarow >= nrow then
		'dbgcons time
		'dbgcons "in 497" 'debug
		Draw String (0,180), "YOU MUST REMOVE SOMETHING!"
		Draw String (0,00), "Me: "
	    Draw String (0,20), "row: " & str (nrow) & "/" & str (nrow) 'xxx draw loses in a raw status
	    Draw String (0,70), "You:" 
	    Draw String (0,90), "row: 0/" & str (nrow) 'xxx draw victories in a raw status
	    
		endif
	if wininarow >= nrow then
		Draw String (0,180), "OPS..I MUST REMOVE SOMETHING"
		Draw String (0,00), "Me: "
	    Draw String (0,20), "row: 0/" & str (nrow) 'xxx draw loses in a raw status
	    Draw String (0,70), "You:" 
	    Draw String (0,90), "row: " & str (nrow) & "/" & str (nrow) 'xxx draw victories in a raw status 
	endif
		Draw String (0,30), "Total: " & Str(totalDealer)
	EndIf 'don't know"
	DrawDeck(80,10,Dealer)
	
	Draw String (0,120), "Total: " & Str(totalPlayer)
	DrawDeck(80,80,Player)
	Draw String (0, 140), Menu
	Draw String (0, 160), Message

	
	ScreenUnLock

	'SetMouse 1, 1, SHOWMOUSE
	
	
	
	If state = GameState.PlayerTurn OrElse state = GameState.GameOver Then
		key = ""
		sleep 99 '3.4
		key = InKey
		GetMouse CurrentX, CurrentY, , MouseButtons
		
		'Mouse handle
		If MouseButtons = LEFTBUTTON then 
			key = "H"
			sleep 99,1
		end if
		If MouseButtons = RIGHTBUTTON then 
			key = "S"
			sleep 99,1
		end if
		
	EndIf
	'Sleep 100


Loop Until key = Chr(27) 'or checkdo = "end"


' send quit to video thread
open wfile FOR OUTPUT AS #7 LEN = 3
print #7, "qui"
CLOSE #7
dbgcons "writed act: qui"

'sleep


'Close #1
'-------------------------------------------------
'Clean up
'-------------------------------------------------

For i As Integer = 1 To 4
	ImageDestroy suitBMP(i)
Next
