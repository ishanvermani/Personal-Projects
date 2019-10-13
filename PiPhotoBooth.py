"""

Raspberry Pi Powered Photo Booth

Involves a USB Webcam, LED's, and the Twython python library

Functions for 
-activating LEDs
-capturing images 
-promting users for thier twitter handles 
-generating an additional message based off the length of inputted message
-uploading combined image and message to twitter using Twitter Authentication Services and the Twython API

August 2015 for the Calgary GAFESummit at Rundle College
"""





#!/usr/bin/python3
from signal import pause
import sys
import pygame
import pygame.camera
from pygame.locals import *
from gpiozero import LED, Button
from twython import Twython
from datetime import datetime
import random
from time import sleep
import os



button = Button(2)
five = LED(7)
four = LED(8)
three = LED(12)
two = LED(16)
one = LED(20)
ledgo = LED(21)



pygame.init()
pygame.camera.init()
cam = pygame.camera.Camera("/dev/video0", (1600,1200))


consumer_key = *
consumer_secret = *
access_key = *
access_secret = *

# Twitter Keys can be found under GAFEphotos Twitter application manager

api = Twython(
    consumer_key,
    consumer_secret,
    access_key,
    access_secret
)
thumsup = [
    '───────────────────████',
    '───────────────────█████',
    '───────────────────██████',
    '───────────────────███████',
    '──────────────────████████',
    '──────────────────████████',
    '─────────────────█████████',
    '────────────────█████████',
    '───────────────█████████',
    '──────────────█████████',
    '──────────────██████████████████',
    '────────────█████████████████████',
    '───────────███████████████████████',
    '████████─██████████████████████████',
    '████████─███████████████████████████',
    '████████─████████████████████████████',
    '████████─████████████████████████████',
    '████████─████████████████████████████',
    '████████─████████████████████████████',
    '████████─███████████████████████████',
    '████████─██████████████████████████',
    '████████─█████████████████████████',
    '████████─████████████████████████',
    '████████─███████████████████████'
]
   
def people(photopath):
    while True:
        username = input("Enter your twitter handles (without the @ sign), separated by a space: ")
        if len(username) < 111:
            break
        else:
            print('Too Many Characters; Try Again')
    if username == "ishanisawesome":
        ask = input("Custom message?")
        if ask == "exit":
            os.system("clear")
            for i in range(5):
                print ('')
            print ("Exiting program... To restart, type 'sudo python3 photobooth.py' ")
            for i in range(5):
                print ('')
            sys.exit()
        elif ask == 'nopic':
            custom = input("Custom message: ")
            if len(custom) < 111:
                api.update_status(status=custom)
            else:
                upload(photopath)
        else:
            return 'ishanisawesome'
    else:
        handles = []
        for item in username.split():
                handles.append(" @" + str(item))
        coolio = "".join(handles)
        return coolio
        

def choose_message(photopath):
    handles = people(photopath)
    length = len(handles)
    if handles == 'ishanisawesome':
        custom = input("Custom Message: ")
        if len(custom) < 111:
            os.system('clear')
            print ("Push Button to take picture")
            return custom
        else:
            upload(photopath)
    else:                 
        if length < 63:
            message = "Learning a lot today at the Calgary #gafesummit!" + handles
            return message
        elif length < 77:
            message = "Lots of cool things at #gafesummit!" + handles
            return message
        elif length < 83:
            message = "Having fun today at #gafesummit!" + handles
            return message
        elif length < 89:
            message = "#gafesummit is awesome!" + handles
            return message
        elif length < 92:
            message = "At #gafesummit with" + handles
            return message
        elif length < 100:
            message = '#gafesummit' + handles
            return message
        else:
            return handles
        
def upload(photopath):
    message = choose_message(photopath)
    photo = open(photopath, "rb")
    response = api.upload_media(media=photo)
    api.update_status(status=message, media_ids=[response['media_id']])
    for i in range(0,3):
        print (' ')
    print('Tweet uploaded: Download it from twitter.com/gafephotos. Enjoy your day!')
    for i in range(0,3):
        print (' ')
    for item in thumsup:
        print (item)

def capture():
    time = datetime.now().isoformat()
    photopath = '/home/pi/photobooth/%s.jpg' % time
    cam.start()    
    image = cam.get_image()
    pygame.image.save(image, photopath)
    cam.stop()
    ledgo.off()
    upload(photopath)

def light_show():
    os.system("clear")
    five.on()
    sleep(1)
    five.off()
    four.on()
    sleep(1)
    four.off()
    three.on()
    sleep(1)
    three.off()
    two.on()
    sleep(1)
    two.off()
    one.on()
    sleep(1)
    one.off()
    ledgo.on()
    capture()           
while True:
    button.when_pressed = light_show
    pause()

    
