from PIL import Image
import sys

try:
    cover_path = sys.argv[1]
    cover_cropped_path = sys.argv[2]
    original_cover = Image.open(cover_path)
    width, height = original_cover.size
    left = width/1.895734597
    top = 0
    right = width
    bottom = height
except:
    pass

try:
    cropped_cover = original_cover.crop((left, top, right, bottom))
    cropped_cover.save(cover_cropped_path)
except:
    pass
