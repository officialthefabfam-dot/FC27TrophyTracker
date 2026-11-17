from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math, os, json

SIZE=1024
im=Image.new("RGB",(SIZE,SIZE),(18,5,8))
px=im.load()
# Rich Liverpool-red radial gradient with dark vignette
for y in range(SIZE):
    for x in range(SIZE):
        dx=(x-SIZE*0.48)/(SIZE*0.78); dy=(y-SIZE*0.42)/(SIZE*0.78)
        glow=max(0,1-math.sqrt(dx*dx+dy*dy))
        vignette=max(0,1-0.22*((x-SIZE/2)**2+(y-SIZE/2)**2)/(SIZE*SIZE/2))
        r=int((35+105*glow)*vignette); g=int((4+12*glow)*vignette); b=int((12+20*glow)*vignette)
        px[x,y]=(r,g,b)
d=ImageDraw.Draw(im)
gold=(238,190,91); bright=(255,224,151); darkgold=(126,78,29); cream=(255,239,198)
# Rounded inset frame
d.rounded_rectangle((42,42,982,982),radius=190,outline=darkgold,width=10)
d.rounded_rectangle((60,60,964,964),radius=174,outline=(186,126,49),width=3)
# Stadium arch / floodlights
d.arc((170,120,854,760),180,360,fill=(112,30,37),width=24)
for side in [0,1]:
    cx=220 if side==0 else 804
    for i in range(5):
        yy=220+i*24
        d.ellipse((cx-8,yy-8,cx+8,yy+8),fill=(245,190,100))
# subtle crowd/stadium tiers
for yy in [685,710,735]:
    d.arc((115,yy-100,909,yy+190),190,350,fill=(102,26,34),width=10)
# trophy cup silhouette
# Handles
d.arc((280,360,470,600),70,290,fill=gold,width=30)
d.arc((554,360,744,600),250,110,fill=gold,width=30)
# Cup bowl
d.polygon([(360,280),(664,280),(634,525),(596,590),(428,590),(390,525)],fill=gold)
d.rounded_rectangle((360,250,664,330),radius=32,fill=bright,outline=darkgold,width=8)
# inner highlight
d.line((414,345,445,510),fill=cream,width=12)
d.line((610,350,588,500),fill=(192,135,55),width=10)
# stem and base
d.rectangle((475,575,549,690),fill=gold)
d.rounded_rectangle((390,675,634,735),radius=22,fill=gold,outline=darkgold,width=8)
d.rounded_rectangle((350,720,674,785),radius=24,fill=bright,outline=darkgold,width=8)
# crown above trophy
d.polygon([(425,225),(452,150),(512,205),(572,150),(600,225)],fill=bright,outline=darkgold)
d.rounded_rectangle((420,220,605,252),radius=10,fill=gold,outline=darkgold,width=6)
for cx in [452,512,572]:
    d.ellipse((cx-10,139,cx+10,159),fill=cream)
# laurel sprigs
for side in [-1,1]:
    points=[]
    for i in range(7):
        yy=430+i*43
        xx=260+side*(i*9)
        d.ellipse((xx-30,yy-18,xx+30,yy+18),outline=gold,width=7)
    d.arc((160 if side<0 else 660,390,365 if side<0 else 865,790),70 if side<0 else 110,290 if side<0 else 250,fill=gold,width=8)
# text
font_paths=["/System/Library/Fonts/Supplemental/Arial Bold.ttf","/Library/Fonts/Arial Bold.ttf"]
font=None
for p in font_paths:
    if os.path.exists(p):
        font=ImageFont.truetype(p,86); break
if font is None: font=ImageFont.load_default()
small=None
for p in font_paths:
    if os.path.exists(p):
        small=ImageFont.truetype(p,34); break
if small is None: small=ImageFont.load_default()
def centered(text,y,f,fill):
    box=d.textbbox((0,0),text,font=f); w=box[2]-box[0]
    d.text(((SIZE-w)/2,y),text,font=f,fill=fill,stroke_width=1,stroke_fill=darkgold)
centered("FC 27",790,font,cream)
centered("TROPHY TRACKER",890,small,gold)
# slight glossy highlight
overlay=Image.new("RGBA",(SIZE,SIZE),(0,0,0,0))
od=ImageDraw.Draw(overlay)
od.rounded_rectangle((85,80,939,944),radius=150,outline=(255,230,170,42),width=5)
im=Image.alpha_composite(im.convert("RGBA"),overlay).convert("RGB")
os.makedirs("Sources/FC27TrophyTracker/Assets.xcassets/AppIcon.appiconset",exist_ok=True)
out="Sources/FC27TrophyTracker/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
im.save(out,optimize=True)
contents={
  "images":[{"filename":"AppIcon.png","idiom":"universal","platform":"ios","size":"1024x1024"}],
  "info":{"author":"xcode","version":1}
}
with open("Sources/FC27TrophyTracker/Assets.xcassets/AppIcon.appiconset/Contents.json","w") as f:
    json.dump(contents,f,indent=2)
print("Generated 1024x1024 Liverpool-inspired AppIcon")
