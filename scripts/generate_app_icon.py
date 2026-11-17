from PIL import Image, ImageDraw, ImageFilter
import math, os, json

SIZE = 1024
im = Image.new("RGB", (SIZE, SIZE))
px = im.load()

# Midnight charcoal field with emerald radial lighting.
for y in range(SIZE):
    for x in range(SIZE):
        dx = (x - 512) / 760
        dy = (y - 490) / 760
        glow = max(0.0, 1.0 - math.sqrt(dx * dx + dy * dy))
        vignette = max(0.58, 1.0 - 0.34 * ((x - 512) ** 2 + (y - 512) ** 2) / (SIZE * SIZE / 2))
        green = int((5 + 42 * glow) * vignette)
        base = int((8 + 7 * glow) * vignette)
        px[x, y] = (base, green, base + 4)

# Restrained diagonal carbon-fibre style bands.
texture = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
td = ImageDraw.Draw(texture)
for offset in range(-SIZE, SIZE * 2, 112):
    td.polygon([(offset, 0), (offset + 38, 0), (offset - 470, SIZE), (offset - 508, SIZE)],
               fill=(170, 190, 180, 13))
im = Image.alpha_composite(im.convert("RGBA"), texture)
d = ImageDraw.Draw(im)

gold = (255, 204, 105, 255)
bright = (255, 232, 170, 255)
shadow_gold = (135, 82, 24, 255)
emerald = (0, 214, 125, 255)
deep_green = (0, 74, 45, 255)

# Soft emerald edge glow, then a clean double frame.
glow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
gd = ImageDraw.Draw(glow_layer)
gd.rounded_rectangle((42, 42, 982, 982), radius=190, outline=(0, 235, 135, 170), width=24)
glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(28))
im = Image.alpha_composite(im, glow_layer)
d = ImageDraw.Draw(im)
d.rounded_rectangle((36, 36, 988, 988), radius=190, outline=gold, width=18)
d.rounded_rectangle((58, 58, 966, 966), radius=168, outline=emerald, width=5)

# Trophy star.
d.polygon([(512, 86), (538, 139), (597, 147), (554, 188), (565, 247),
           (512, 219), (459, 247), (470, 188), (427, 147), (486, 139)],
          fill=bright, outline=shadow_gold)
d.line((512, 91, 512, 218), fill=gold, width=4)

# Laurel branches, built from individual gold leaves.
for side in (-1, 1):
    pts = []
    for i in range(9):
        t = i / 8
        x = 230 + int(115 * t) if side == -1 else 794 - int(115 * t)
        y = 760 - int(390 * t)
        pts.append((x, y))
        leaf_x = x - 34 if side == -1 else x + 34
        leaf_y = y - 2
        bbox = (min(x, leaf_x) - 25, leaf_y - 26, max(x, leaf_x) + 25, leaf_y + 26)
        d.ellipse(bbox, fill=gold, outline=shadow_gold, width=3)
    d.line(pts, fill=bright, width=8, joint="curve")

# Trophy handles.
d.arc((250, 285, 470, 650), 55, 300, fill=gold, width=34)
d.arc((554, 285, 774, 650), 240, 125, fill=gold, width=34)

# Cup bowl with layered metallic highlights.
d.polygon([(365, 275), (659, 275), (632, 520), (590, 605),
           (434, 605), (392, 520)], fill=gold, outline=shadow_gold)
d.rounded_rectangle((354, 252, 670, 328), radius=30, fill=bright, outline=shadow_gold, width=9)
d.polygon([(405, 346), (438, 354), (458, 530), (432, 520)], fill=(255, 238, 190, 210))
d.polygon([(617, 350), (641, 344), (591, 520), (570, 530)], fill=(176, 112, 35, 190))
d.line((390, 535, 634, 535), fill=bright, width=7)

# Stem and stepped plinth.
d.rounded_rectangle((474, 585, 550, 735), radius=18, fill=gold, outline=shadow_gold, width=7)
d.rounded_rectangle((414, 700, 610, 758), radius=18, fill=bright, outline=shadow_gold, width=8)
d.rounded_rectangle((365, 746, 659, 820), radius=24, fill=gold, outline=shadow_gold, width=9)
d.line((395, 773, 629, 773), fill=bright, width=5)

# Subtle emerald highlights around the central emblem.
d.arc((100, 100, 924, 924), 198, 342, fill=emerald, width=5)
d.arc((112, 112, 912, 912), 18, 162, fill=deep_green, width=5)

out_dir = "Sources/FC27TrophyTracker/Assets.xcassets/AppIcon.appiconset"
os.makedirs(out_dir, exist_ok=True)
out = os.path.join(out_dir, "AppIcon.png")
im.convert("RGB").save(out, optimize=True)
contents = {
    "images": [{"filename": "AppIcon.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}],
    "info": {"author": "xcode", "version": 1}
}
with open(os.path.join(out_dir, "Contents.json"), "w") as f:
    json.dump(contents, f, indent=2)
print("Generated emerald-and-gold trophy app icon")
