from sys import argv
from pathlib import Path

import PIL.Image

RESULT_PATH = "src/asset_mem.mem"
SOURCE_IMAGES = ["bird.png", "digits.png"]

result = []

for image_path in SOURCE_IMAGES:
    image = PIL.Image.open(image_path)

    print(
        f"{image_path} ({image.size[0]}x{image.size[1]}): {len(result)}..{len(result) + (image.size[0] * image.size[1]) - 1}"
    )

    for y in range(image.size[1]):
        for x in range(image.size[0]):
            result.append(image.getpixel((x, y)))

Path(RESULT_PATH).write_text("\n".join(map(str, result)))
