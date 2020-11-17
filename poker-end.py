from tkinter import *
#from PIL import Image
explanation = """You beat me, my compliments...  
we can continue playing cards if you want.."""
root = Tk()
root.call('wm', 'attributes', '.', '-topmost', '1')
root.title("my compliments..")
#image = Image.open("image.jpg")
w = 230
h = 230
#image = image.resize((w, h), Image.ANTIALIAS)
#image.save("image_mini.png")
#miniimage = PhotoImage(file="image_mini.png")
#label_image = Label(root, image=miniimage).pack(side="right")

label_text = Label(root,
                    font=("Helvetica", 16),
                    padx = 25,
                    text=explanation).pack(side="left")
root.mainloop()
print ("program ended!")
