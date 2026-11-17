from PIL import Image, ImageDraw, ImageFont
import math
import os
import json

SIZE = 1024
image = Image.new("RGB", (SIZE, SIZE))
pixels = image.load()

# Neutral midnight-blue gradient: the app's default identity is not tied to a club.
for y in range(SIZE):
    for x in range(SIZE):
        dx = (x - SIZE * 0.48) / (SIZE * 0.82)
        dy = (y - SIZE * 0.40) / (SIZE * 0.82)
        glow = max(0.0, 1.0 - math.sqrt(dx * dx + dy * dy))
        vignette = max(0.72, 1.0 - 0.20 * ((x - SIZE / 2) ** 2 + (y - SIZE / 2) ** 2) / (SIZE * SIZE / 2))
        pixels[x, y] = (
            int((13 + 40 * glow) * vignette),
            int((22 + 63 * glow) * vignette),
            int((39 + 105 * glow) * vignette),
        )

draw = ImageDraw.Draw(image)
accent = (92, 151, 245)
gold = (245, 202, 117)
pale = (255, 238, 194)
bronze = (135, 91, 43)

# Subtle inset frame and stadium-like arcs.
draw.rounded_rectangle((42, 42, 982, 982), radius=190, outline=(65, 101, 151), width=8)
draw.rounded_rectangle((60, 60, 964, 964), radius=174, outline=(111, 150, 199), width=3)
draw.arc((160, 115, 864, 730), 180, 360, fill=(71, 105, 151), width=14)
draw.arc((220, 170, 804, 680), 180, 360, fill=(53, 82, 121), width=8)

# Trophy handles.
draw.arc((275, 350, 475, 610), 65, 295, fill=gold, width=28)
draw.arc((549, 350, 749, 610), 245, 115, fill=gold, width=28)

# Cup bowl, rim, stem and base.
draw.polygon([(360, 270), (664, 270), (635, 515), (596, 580), (428, 580), (389, 515)], fill=gold)
draw.rounded_rectangle((350, 240, 674, 322), radius=30, fill=pale, outline=bronze, width=8)
draw.line((405, 345, 438, 500), fill=(255, 247, 218), width=12)
draw.line((616, 345, 588, 500), fill=(190, 139, 73), width=10)
draw.rectangle((476, 570, 548, 690), fill=gold)
draw.rounded_rectangle((390, 675, 634, 735), radius=20, fill=gold, outline=bronze, width=8)
draw.rounded_rectangle((350, 720, 674, 785), radius=22, fill=pale, outline=bronze, width=8)

# Small accent stars.
for cx, cy, radius in [(300, 270, 13), (724, 270, 13), (512, 180, 17)]:
    draw.ellipse((cx-radius, cy-radius, cx+radius, cy+radius), fill=accent, outline=pale, width=3)

font_paths = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/Library/Fonts/Arial Bold.ttf",
]
def load_font(size):
    for path in font_paths:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()

def centered(label, y, font, fill):
    bounds = draw.textbbox((0, 0), label, font=font)
    draw.text(((SIZE - (bounds[2] - bounds[0])) / 2, y), label,
              font=font, fill=fill, stroke_width=1, stroke_fill=(22, 36, 56))

centered("FC 27", 790, load_font(86), (255, 255, 255))
centered("TROPHY TRACKER", 890, load_font(34), accent)

os.makedirs("Sources/FC27TrophyTracker/Assets.xcassets/AppIcon.appiconset", exist_ok=True)
output = "Sources/FC27TrophyTracker/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
image.save(output, optimize=True)

contents = {
    "images": [{"filename": "AppIcon.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}],
    "info": {"author": "xcode", "version": 1}
}
with open("Sources/FC27TrophyTracker/Assets.xcassets/AppIcon.appiconset/Contents.json", "w") as file:
    json.dump(contents, file, indent=2)

print("Generated neutral FC 27 Trophy Tracker app icon")
