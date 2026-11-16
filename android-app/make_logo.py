#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从 Project Helix 截图提取圆形 logo 图案，生成 Helixbox Android 图标。
   用法：python3 make_logo.py
"""
from PIL import Image, ImageDraw, ImageFilter
import os

SRC = r"C:\Users\LiuXiao\.workbuddy\clipboard-images\clipboard-2026-11-16T09-43-15-163Z-36d2b0c5.webp"
BASE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(BASE, "android", "app", "src", "main", "res")
ASSETS = os.path.join(BASE, "assets")
os.makedirs(ASSETS, exist_ok=True)

# ---------- 1. 裁出圆形图案（中心 960,475，半径约 130）----------
img = Image.open(SRC).convert("L")
box = (828, 343, 1092, 607)  # 264x264，含图案与少量黑边
crop = img.crop(box)

# ---------- 2. 黑底转透明：亮度作为 alpha，图形本身纯白 ----------
# 图案是白色描边在黑底上，直接把灰度当 alpha，白=不透明，黑=透明
alpha = crop  # L 模式即灰度
white = Image.new("RGBA", crop.size, (255, 255, 255, 0))
white.putalpha(alpha)
# 略微增强对比，让白色更纯、黑底更透
def boost(a):
    return 0 if a < 24 else 255 if a > 200 else int((a - 24) * 255 / 176)
white = white.point(lambda v: v)  # alpha 已在 putalpha
rgba = white.split()
new_alpha = rgba[3].point(boost)
white.putalpha(new_alpha)

# 裁到图案实际边界（去掉多余透明边）
bbox = white.getchannel("A").getbbox()
helix = white.crop(bbox) if bbox else white
print("图案尺寸:", helix.size)

# ---------- 3. 合成图标：深色圆角底 + 居中 Helix 图案 ----------
def make_icon(size, round_icon=False):
    S = size * 4  # 超采样抗锯齿
    canvas = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(canvas)
    # 背景：Helixbox 深墨色圆角方形（或圆形）
    pad = int(S * 0.03)
    if round_icon:
        d.ellipse([pad, pad, S - pad, S - pad], fill=(15, 20, 26, 255))
    else:
        d.rounded_rectangle([pad, pad, S - pad, S - pad], radius=int(S * 0.22), fill=(15, 20, 26, 255))
    # 图案缩放居中（占约 78%）
    target = int(S * 0.78)
    h = helix.resize((target, target), Image.LANCZOS)
    x = (S - target) // 2
    y = (S - target) // 2
    canvas.alpha_composite(h, (x, y))
    return canvas.resize((size, size), Image.LANCZOS)

# ---------- 4. 写入各密度 mipmap ----------
DENSITIES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
for folder, sz in DENSITIES.items():
    d = os.path.join(RES, folder)
    os.makedirs(d, exist_ok=True)
    make_icon(sz).save(os.path.join(d, "ic_launcher.png"))
    make_icon(sz, round_icon=True).save(os.path.join(d, "ic_launcher_round.png"))
    print(f"{folder}: {sz}px x2")

# ---------- 5. App 内嵌高清 logo（首页头图用）----------
make_icon(512).save(os.path.join(ASSETS, "helixbox_logo.png"))
# 纯图案透明版（可叠在渐变头图上）
helix.resize((512, 512), Image.LANCZOS).save(os.path.join(ASSETS, "helix_mark.png"))
print("已生成 assets/helixbox_logo.png 与 assets/helix_mark.png")
