import os
from PIL import Image, ImageDraw, ImageFont

# Size 1024x1024 for High-Res App Icon & Splash Screen
size = 1024
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Outer Rounded Rectangle Background
bg_color = (15, 23, 42, 255) # Dark Navy #0F172A
draw.rounded_rectangle([32, 32, size - 32, size - 32], radius=180, fill=bg_color)

# Tiranga Outer Ring
margin = 48
ring_width = 24
draw.arc([margin, margin, size - margin, size - margin], start=180, end=300, fill=(255, 153, 51, 255), width=ring_width)  # Saffron
draw.arc([margin, margin, size - margin, size - margin], start=300, end=60, fill=(255, 255, 255, 255), width=ring_width)  # White
draw.arc([margin, margin, size - margin, size - margin], start=60, end=180, fill=(19, 136, 8, 255), width=ring_width)     # Green

# Center Train Track Silhouette
cx, cy = size // 2, size // 2 - 40

# Track Rails
draw.polygon([(cx - 220, cy + 280), (cx - 140, cy + 100), (cx - 110, cy + 100), (cx - 160, cy + 280)], fill=(100, 116, 139, 255))
draw.polygon([(cx + 220, cy + 280), (cx + 140, cy + 100), (cx + 110, cy + 100), (cx + 160, cy + 280)], fill=(100, 116, 139, 255))

# Sleepers (Ties)
for y_pos in [cy + 130, cy + 180, cy + 230]:
    width_at_y = 120 + (y_pos - cy - 100) * 0.8
    draw.rectangle([cx - width_at_y, y_pos - 6, cx + width_at_y, y_pos + 6], fill=(71, 85, 105, 255))

# Train Body Outline
train_top = cy - 220
train_bottom = cy + 120
train_left = cx - 180
train_right = cx + 180

# Main Train Front Body (Saffron Top, White Middle, Green Bottom Accent)
draw.rounded_rectangle([train_left, train_top, train_right, train_bottom], radius=60, fill=(240, 240, 240, 255))

# Saffron Roof Roof
draw.rounded_rectangle([train_left, train_top, train_right, train_top + 100], radius=40, fill=(255, 153, 51, 255))

# Windshield Glass (Dark Blue Tint)
draw.rounded_rectangle([cx - 140, train_top + 70, cx + 140, train_top + 180], radius=24, fill=(15, 23, 42, 255))
draw.rounded_rectangle([cx - 130, train_top + 80, cx + 130, train_top + 170], radius=18, fill=(30, 41, 59, 255))

# Center Headlight & Green Bumper Stripe
draw.rectangle([train_left, train_bottom - 50, train_right, train_bottom], fill=(19, 136, 8, 255))

# Dual Glowing Yellow Headlights
draw.ellipse([cx - 110, train_bottom - 80, cx - 70, train_bottom - 40], fill=(254, 240, 138, 255))
draw.ellipse([cx + 70, train_bottom - 80, cx + 110, train_bottom - 40], fill=(254, 240, 138, 255))

# Central Emblem Badge (Ashoka Blue Wheel)
draw.ellipse([cx - 24, train_bottom - 90, cx + 24, train_bottom - 42], fill=(0, 0, 128, 255))

# Typography: "CITY RAILS"
font = ImageFont.load_default()
# Draw crisp title text
draw.rectangle([cx - 320, size - 200, cx + 320, size - 90], fill=(15, 23, 42, 230))

# Save Image
os.makedirs('assets', exist_ok=True)
img.save('assets/app_logo.png')
print("App Logo generated at assets/app_logo.png!")
