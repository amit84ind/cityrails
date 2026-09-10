import os
from PIL import Image

logo_path = 'assets/app_logo.png'
if not os.path.exists(logo_path):
    print("Logo file not found!")
    exit(1)

img = Image.open(logo_path)

# Android Mipmap dimensions
mipmap_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

base_res_dir = 'android/app/src/main/res'

for folder, dim in mipmap_sizes.items():
    target_dir = os.path.join(base_res_dir, folder)
    os.makedirs(target_dir, exist_ok=True)

    resized_img = img.resize((dim, dim), Image.Resampling.LANCZOS)
    target_path = os.path.join(target_dir, 'ic_launcher.png')
    resized_img.save(target_path)
    print(f"Saved {target_path} ({dim}x{dim})")

print("All Android launcher icons generated successfully!")
