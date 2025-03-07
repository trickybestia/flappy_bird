import PIL.Image
from sys import argv

image = PIL.Image.open(argv[1])

print(image.size)

for y in range(image.size[1]):
    for x in range(image.size[0]):
        print(image.getpixel((x, y)))
