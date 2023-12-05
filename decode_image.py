import os
import imageio
from scipy import misc
# path = '/Users/ryk70/Downloads/'
# Replace the following with the name of your bmp image
image = imageio.imread('pixil-frame-0.bmp')

def conv_2bits(color):
    if color < 64:
        return 0b00
    elif color < 128:
        return 0b01
    elif color < 192:
        return 0b10
    else:
        return 0b11

x = 0b0000
y = 0b0000

for i in image:
    for j in i:
        r = conv_2bits(j[0])
        g = conv_2bits(j[1])
        b = conv_2bits(j[2])
        print(f"when {x:04b}{y:04b} => rgb <= {r:02b}{g:02b}{g:02b};")
        x += 1;
    y += 1
    x = 0;

