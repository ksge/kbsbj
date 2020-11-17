#1 removed comp2 and comp3
#2 opponent for computer 1
#3 screen layout reorganization
#6 handle disable button during important clip scenes
#7 python 3 translation
#8 if ksge outputs "end" then quit game
#9 mp3 soundtrack support added

# tested with python3.7
# pygame is needed install with pip install pygame


# for deployment pyinstaller is needed install with pip install pyinstaller


#deploy with pyinstaller /home/*/.local/bin/pyinstaller --onefile PokerView.py
#deploy with pyinstaller /home/*/.local/bin/pyinstaller --onefile PokerModel.py
#deploy with C:\Users\*\AppData\Local\Programs\Python\Python37\Scripts\pyinstaller.exe --onefile PokerView.py
#deploy with C:\Users\*\AppData\Local\Programs\Python\Python37\Scripts\pyinstaller.exe --onefile PokerModel.py


import pygame
import os,sys
import PokerModel
import platform #5
from pygame import mixer #9



#3HEIGHT = 720
#3WIDTH = 640


###############################################Global constants here
gname = "KISS Strip Poker" # game name 5
modelname = "DEMO" # model/dir name #5
wcou = 3
if platform.system() == "Windows": #5
	wdir = ".ksge"
	wfile = ".ksge\\action"+modelname  #5
else:
	wdir = "/dev/shm/.ksge"
	wfile = "/dev/shm/.ksge/action"+modelname #5
BLACK = (255,255,255)
BLACK = (0,0,0)
GREY  = (50,50,50)
RED  = (207,0,0)
PINK = (255,192,203)
BLUE = (176,224,230)
YELLOW = (255,223,0)
SALMON = (250,128,114)

gameIcon = pygame.image.load('icon.png')
pygame.display.set_icon(gameIcon)
#################################################

#9 ************
# Starting the mixer 
mixer.init() 

# Loading the song 
mixer.music.load("song.mp3") 

# Setting the volume 
mixer.music.set_volume(0.7) 

# Start playing the song 
mixer.music.play(-1) 
#9 ************

class Control:
	def __init__(self):
		deck = PokerModel.Deck()
		self.images = {}
		self.scale = .5
		self.cardSize = (WIDTH / 3, WIDTH / 2) #3 cards size calculated by screen resolution
		self.buffer = 50
		self.background = pygame.image.load('img/background.jpg').convert_alpha()
		self.cardBack = pygame.image.load('img/back.png').convert_alpha()
		self.cardBack = pygame.transform.scale(self.cardBack,(int(self.scale * self.cardSize[0]), int(self.scale * self.cardSize[1])))


		font = pygame.font.Font('font/CoffeeTin.ttf', 50)
		loadText = font.render("Loading...", 1, BLACK)
		loadSize = font.size("Loading...")
		loadLoc = (WIDTH/2 - loadSize[0]/2, HEIGHT/2 - loadSize[1]/2)

		#3self.scores = [0,0,0,0]
		self.scores = [0,0]

		SCREEN.blit(self.background, (-320,-100))

		SCREEN.blit(loadText, loadLoc)

		pygame.display.flip()

		for card in deck:
			self.images[str(card)] = pygame.image.load(card.image_path).convert_alpha()
			self.images[str(card)] = pygame.transform.scale(self.images[str(card)], (int(self.scale * self.cardSize[0]), int(self.scale * self.cardSize[1])))

		self.start_up_init()

	def main(self):
		if self.state == 0:
			self.start_up()
		elif self.state == 1:
			self.play()
		elif self.state == 2:
			self.results()
		elif self.state == 3:
			self.new_game()

	def start_up_init(self):
		#intitialize items for the startup section of the game
		self.poker = PokerModel.Poker(self.scores)

		self.font = pygame.font.Font('font/CoffeeTin.ttf',70) #3 welcome start button size
		self.font2 = pygame.font.Font('font/IndianPoker.ttf', 35) #3 welcome font size
		self.font2.set_bold(True)

		self.startText = self.font2.render(gname, 1, BLACK)
		self.startSize = self.font2.size(gname)
		self.startLoc = (WIDTH/2 - self.startSize[0]/2, self.buffer)

		self.startButton = self.font.render(" Start ", 1, BLACK)
		self.buttonSize =self.font.size(" Start ")
		self.buttonLoc = (WIDTH/2 - self.buttonSize[0]/2, HEIGHT/2 - self.buttonSize[1]/2)

		self.buttonRect = pygame.Rect(self.buttonLoc, self.buttonSize)
		self.buttonRectOutline = pygame.Rect(self.buttonLoc, self.buttonSize)

		self.state = 0

	def start_up(self):
		
		#8
		xwai = "act"
		f = open(wfile, "r")
		xwai = f.read()
		f.close() 
		if xwai == "end":
			print ("u won!")
			pygame.quit();sys.exit()
		##

		for event in pygame.event.get():
			#if user clicks close windows game closes ksge
			if event.type == pygame.QUIT:
				print ("game window closed")
				f = open(wfile, "w")
				f.write("qui")
				f.close() 
				mixer.music.stop() #9 
				pygame.quit();sys.exit()
			#when the user clicks the start button, change to the playing state
			elif event.type == pygame.MOUSEBUTTONDOWN:
				if event.button == 1:
					mouseRect = pygame.Rect(event.pos, (1,1))
					if mouseRect.colliderect(self.buttonRect):
						self.state += 1
						self.play_init()
						return

		#draw background
		SCREEN.blit(self.background, (-320,-100))

		#draw welcome text
		SCREEN.blit(self.startText, self.startLoc)

		#draw the start button
		pygame.draw.rect(SCREEN, RED, self.buttonRect)
		pygame.draw.rect(SCREEN, BLACK, self.buttonRectOutline, 2)
		SCREEN.blit(self.startButton, self.buttonLoc)

		pygame.display.flip()

	def play_init(self):
		#create the new variables
		self.cardLoc = {}
		self.round = 0

		#setup the locations for each card in the hand
		#3x = 4.5 * int(self.scale * self.cardSize[0])
		x = 10 #3 x position of player cards
		#3y = 270 #3 y position of player cards
		y = HEIGHT * 30 / 100 #3 y position of player cards
		xb = 10 #3 x position of replace/new game button
		yb = HEIGHT * 15 / 100 #3 y position of replace/new game button
		
		#3self.youLoc = (x - 150, self.buffer)
		self.youLoc = (x, self.buffer)

		for index in range(len(self.poker.playerHand)):
			#3self.cardLoc[index] = (x, self.buffer)
			self.cardLoc[index] = (x, y)
			x += int(self. scale * self.cardSize[0])

		#setup the text that will be printed to the screen
		self.font = pygame.font.Font('font/IndianPoker.ttf', 25)
		self.font.set_bold(True)
		self.font2 = pygame.font.Font('font/CoffeeTin.ttf', 60)
		self.youText = self.font.render("Your Hand", 1, BLUE) # font color
		self.youSize = self.font.size("Your Hand")

		self.youLoc = (self.cardLoc[0][0],self.cardLoc[0][1] - 30)#(self.youLoc[0], self.buffer + self.scale * self.cardSize[1]/2 - self.youSize[1]/2)

		self.replaceButton = self.font2.render(" Replace ", 1, BLACK)
		self.buttonSize =self.font2.size(" Replace ")

		#3self.buttonLoc = (x + 30, self.buffer + self.scale * self.cardSize[1]/2 - self.buttonSize[1]/2)
		self.buttonLoc = (xb, yb)
		
		self.buttonRect = pygame.Rect(self.buttonLoc, self.buttonSize)
		self.buttonRectOutline = pygame.Rect(self.buttonLoc, self.buttonSize)

	def play(self):
		#8
		xwai = "act"
		f = open(wfile, "r")
		xwai = f.read()
		f.close() 
		if xwai == "end":
			print ("u won!")
			pygame.quit();sys.exit()
		##
		for event in pygame.event.get():
			#if user clicks close windows game closes ksge
			if event.type == pygame.QUIT:
				print ("game window closed")
				f = open(wfile, "w")
				f.write("qui")
				f.close() 
				mixer.music.stop() #9 
				pygame.quit();sys.exit()
			#when the user clicks on a card, change its color to signify a selection has occurred
			elif event.type == pygame.MOUSEBUTTONDOWN:
				if event.button == 1:
					#create a rectangle for the mouse click and for each card.  check for intersection
					mouseRect = pygame.Rect(event.pos, (1,1))
					for index in range(len(self.poker.playerHand)):									#this minus thirty fixes a minor bug, do not remove
						cardRect = pygame.Rect(self.cardLoc[index], (int(self.scale * self.cardSize[0]), int(self.scale * self.cardSize[1])))
						if cardRect.colliderect(mouseRect):
							self.poker.playerHand[index].selected = not self.poker.playerHand[index].selected
							break

					#check if we clicked the replaceButton
					if mouseRect.colliderect(self.buttonRect):
						#8
						xwai = "act"
						f = open(wfile, "r")
						xwai = f.read()
						f.close() 
						print (xwai)
						if xwai == "end":
							print ("u won!")
							pygame.quit();sys.exit()
						##
						self.poker.replace(self.poker.playerHand)
						self.poker.computerReplace()
						self.round += 1
						if self.round == 2:
							self.state += 1
							self.results_init()
							return

		#display background	
		SCREEN.blit(self.background, (-320,-100))

		#display the player's hand
		for index in range(len(self.poker.playerHand)):
			if not self.poker.playerHand[index].selected:
				SCREEN.blit(self.images[str(self.poker.playerHand[index])], self.cardLoc[index])
			else:
				SCREEN.blit(self.cardBack, self.cardLoc[index])

		#display the text
		SCREEN.blit(self.youText, self.youLoc)
		pygame.draw.rect(SCREEN, RED, self.buttonRect)
		pygame.draw.rect(SCREEN, BLACK, self.buttonRectOutline, 2)
		SCREEN.blit(self.replaceButton, self.buttonLoc)

		#display the scoreboard
		self.display_scoreboard()

		pygame.display.flip()

	def results_init(self):
		xbb = 10 #3 x position of replace/new game button
		ybb = HEIGHT * 15 / 100 #3 y position of replace/new game button
		xo = 10 #3 position of opponents cards
		#3yo = 580 #3 position of opponent cards
		yo = HEIGHT * 55 / 100 #3 position of opponent cards
		#initialize variables for the button
		# self.font = pygame.font.Font('font/IndianPoker.ttf', 25)
		self.replaceButton = self.font2.render(" New Game ", 1, BLACK)
		self.buttonSize =self.font2.size(" New Game ")

		#3self.buttonLoc = (self.buttonLoc[0], self.buffer + self.scale * self.cardSize[1]/2 - self.buttonSize[1]/2)
		self.buttonLoc = (xbb,ybb)

		self.buttonRect = pygame.Rect(self.buttonLoc, self.buttonSize)
		self.buttonRectOutline = pygame.Rect(self.buttonLoc, self.buttonSize)

		#initialize variables for drawing the hands
		#3self.comp1Loc = (self.buffer, HEIGHT / 2 - self.scale * self.cardSize[1]/2)
		self.comp1Loc = (xo, yo)
		#1self.comp2Loc = (WIDTH - int(5 * self.scale * self.cardSize[0]) - self.buffer, HEIGHT / 2 - self.scale * self.cardSize[1]/2)
		#1self.comp3Loc = ( 4.5 * int(self.scale * self.cardSize[0]), HEIGHT - self.scale * self.cardSize[1] - self.buffer)

		self.result = self.poker.play_round()

		#initialize variables for labeling the hands
		playerScore = self.poker.convert_score(self.result[0])
		#3self.youText = self.font.render(playerScore, 1, BLACK)
		self.youText = self.font.render(playerScore, 1, BLUE) #3 font color
		self.youSize = self.font.size(playerScore)
		self.youLoc = (self.cardLoc[0][0],self.cardLoc[0][1] - 30)

		comp1Score = self.poker.convert_score(self.result[1])
		self.comp1Label = self.font.render(comp1Score, 1, PINK) #3 font color
		self.comp1LabelSize = self.font.size(comp1Score)
		self.comp1LabelLoc = (self.comp1Loc[0], self.comp1Loc[1] - 30)

		#1comp2Score = self.poker.convert_score(self.result[2])
		#1self.comp2Label = self.font.render(comp2Score, 1, BLACK)
		#1self.comp2LabelSize = self.font.size(comp2Score)
		#1self.comp2LabelLoc = (self.comp2Loc[0], self.comp2Loc[1] - 30)

		#1comp3Score = self.poker.convert_score(self.result[3])
		#1self.comp3Label = self.font.render(comp3Score, 1, BLACK)
		#1self.comp3LabelSize = self.font.size(comp3Score)
		#1self.comp3LabelLoc = (self.comp3Loc[0], self.comp3Loc[1] - 30)

	def results(self):
		#8
		xwai = "act"
		f = open(wfile, "r")
		xwai = f.read()
		f.close() 
		if xwai == "end":
			print ("u won!")
			pygame.quit();sys.exit()
		##
		for event in pygame.event.get():
			if event.type == pygame.QUIT:
				print ("game window closed")
				f = open(wfile, "w")
				f.write("qui")
				f.close() 
				mixer.music.stop() #9 
				pygame.quit();sys.exit()
			#when the user clicks the start button, change to the playing state
			elif event.type == pygame.MOUSEBUTTONDOWN:
				if event.button == 1:
					mouseRect = pygame.Rect(event.pos, (1,1))
					if mouseRect.colliderect(self.buttonRect):
						# self.start_up_init()
						self.state = 1
						self.play_init()
						self.poker = PokerModel.Poker(self.scores)
						return

		#display background
		SCREEN.blit(self.background, (-320,-100))

		#print player hand in the top
		self.display_hand(self.poker.playerHand, self.cardLoc[0][0], self.cardLoc[0][1])

		#print Opponent on the left
		self.display_hand(self.poker.comp1Hand, self.comp1Loc[0], self.comp1Loc[1])

		#print computer 2 on the right
		#1self.display_hand(self.poker.comp2Hand,self.comp2Loc[0], self.comp2Loc[1])

		#print computer 3 on the bottom
		#1self.display_hand(self.poker.comp3Hand, self.comp3Loc[0], self.comp3Loc[1])

		#print labels saing what each hand was
		SCREEN.blit(self.youText, self.youLoc)
		SCREEN.blit(self.comp1Label, self.comp1LabelLoc)
		#1SCREEN.blit(self.comp2Label, self.comp2LabelLoc)
		#1SCREEN.blit(self.comp3Label, self.comp3LabelLoc)

		#display a score screen
		self.display_scoreboard()

		#display a play again button
		pygame.draw.rect(SCREEN, RED, self.buttonRect)
		pygame.draw.rect(SCREEN, BLACK, self.buttonRectOutline, 2)
		SCREEN.blit(self.replaceButton, self.buttonLoc)

		pygame.display.flip()

	def display_hand(self, hand, x, y):
		for card in hand:
			SCREEN.blit(self.images[str(card)], (x, y))
			x += int(self.scale * self.cardSize[0])

	def display_scoreboard(self):
		
		
		#youscold = self.poker.scores[0] #3
		#mescold = self.poker.scores[1] #3
		
		#create labels for each player
		self.playerScoreLabel = self.font.render("You: " +str(self.poker.scores[0])+ "/"+ str(wcou), 1, BLUE) # font color
		self.comp1ScoreLabel = self.font.render("Me: "  +str(self.poker.scores[1])+ "/"+ str(wcou), 1, PINK) # font color
		
		#1self.comp2ScoreLabel = self.font.render("Computer 2: "  +str(self.poker.scores[2]), 1, BLACK)
		#1self.comp3ScoreLabel = self.font.render("Computer 3: "  +str(self.poker.scores[3]), 1, BLACK)

		SCREEN.blit(self.playerScoreLabel, (10, 10)) #font positions
		SCREEN.blit(self.comp1ScoreLabel, (10, 40))
		
		#1SCREEN.blit(self.comp2ScoreLabel, (10, 70))
		#1SCREEN.blit(self.comp3ScoreLabel, (10, 100))
		

#############################################################
if __name__ == "__main__":
	#3os.environ['SDL_VIDEO_CENTERED'] = '1' #center screen
	
	
	pygame.init()
	pygame.display.set_caption(gname)
	SRESX, SRESY = (pygame.display.Info().current_w), (pygame.display.Info().current_h)
	WIDTH, HEIGHT = (pygame.display.Info().current_w * 25 // 100), (pygame.display.Info().current_h * 70 // 100) #3 window size calculated by % of screen resolution
	os.environ['SDL_VIDEO_WINDOW_POS'] = str(SRESX - WIDTH) + "," + str(SRESY - HEIGHT) #window position
	SCREEN = pygame.display.set_mode((WIDTH, HEIGHT), 0 ,32)
	
	Runit = Control()
	Myclock = pygame.time.Clock()
	while 1:
		Runit.main()
		Myclock.tick(64)
