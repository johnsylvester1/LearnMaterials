#!/usr/bin/python
import RPi.GPIO as GPIO
import time
 
#GPIO SETUP
# Corresponds to GPIO 4 ( position of Pin is 7 )

gpiopin4 = 4
GPIO.setmode(GPIO.BCM)
GPIO.setup(gpiopin4, GPIO.IN)

 
def callback(gpiopin4):
    
        if GPIO.input(gpiopin4):
                       
                print "Sound Detected by Sensor!" 
           
                 
# Intimate when the pin goes HIGH / LOW 

GPIO.add_event_detect(gpiopin4, GPIO.BOTH, bouncetime=300)  

# assign function to GPIO PIN, Run function on change

GPIO.add_event_callback(gpiopin4, callback)  
 
# infinite loop
while True:
        time.sleep(1)
