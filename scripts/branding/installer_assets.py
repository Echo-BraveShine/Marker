#!/usr/bin/env python3
"""Render editable installer artwork using the existing Marker logo.
Development only: pip install cairosvg pillow. Generated assets are committed.
"""
import base64
from io import BytesIO
import os
from pathlib import Path
import cairosvg
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
LOGO = base64.b64encode((ROOT / 'assets/branding/marker-light.png').read_bytes()).decode()
FONT = 'PingFang SC,Helvetica Neue,Noto Sans CJK SC,Arial,sans-serif'

def image(x, y, size):
    return f'<image x="{x}" y="{y}" width="{size}" height="{size}" href="data:image/png;base64,{LOGO}"/>'

def label(x,y,size,text,color='#102b4d',weight=400,anchor='start'):
    return f'<text x="{x}" y="{y}" font-family="{FONT}" font-size="{size}" fill="{color}" font-weight="{weight}" text-anchor="{anchor}">{text}</text>'

def render(path, width, height, content):
    target=ROOT/path
    target.parent.mkdir(parents=True,exist_ok=True)
    svg=f'''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
<defs><linearGradient id="bg" x2="1" y2="1"><stop stop-color="#f7f9fc"/><stop offset="1" stop-color="#e1f2f0"/></linearGradient></defs>{content}</svg>'''
    reference = os.path.relpath(ROOT / 'assets/branding/marker-light.png', target.parent)
    source = svg.replace(f'data:image/png;base64,{LOGO}', reference)
    target.with_suffix('.svg').write_text(source,encoding='utf-8')
    data=cairosvg.svg2png(bytestring=svg.encode())
    if target.suffix=='.bmp':
        Image.open(BytesIO(data)).convert('RGB').save(target)
    else:target.write_bytes(data)

# Finder supplies the real application and Applications icons over this backdrop.
render(Path('.github/release/macos-background.png'),660,420,
 '<rect width="660" height="420" fill="url(#bg)"/>'
 +label(34,102,106,'#', '#cfe1e9',600)+label(549,328,92,'M','#d4e9e6',600)
 +label(330,64,32,'Marker',weight=600,anchor='middle')
 +label(330,96,14,'让灵感，自在落笔。','#607285',anchor='middle')
 +label(330,118,12,'A little space for your next idea.','#607285',anchor='middle')
 +'<path d="M306 228h48m-12-12 12 12-12 12" fill="none" stroke="#3b8c95" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>'
 +'<path d="M76 343h508" stroke="#d5e2e7"/>'
 +label(330,372,14,'将 Marker 拖入 Applications，即可安装。','#607285',anchor='middle')
 +label(330,396,12,'Drag Marker into Applications to install.','#607285',anchor='middle'))

side='<rect width="164" height="314" fill="url(#bg)"/>'+image(34,43,96)+label(82,171,23,'Marker',weight=600,anchor='middle')+label(82,196,11,'让灵感，自在落笔。','#607285',anchor='middle')+label(82,218,9,'Make room for words.','#607285',anchor='middle')+'<path d="M40 252h84" stroke="#bdD5d8"/>'+label(82,276,9,'MARKDOWN · MADE SIMPLE','#607285',anchor='middle')
render(Path('windows/installer/wizard-sidebar.bmp'),164,314,side)
render(Path('windows/installer/wizard-dialog.bmp'),493,312,'<rect width="493" height="312" fill="white"/>'+side)
render(Path('windows/installer/wizard-banner.bmp'),493,58,'<rect width="493" height="58" fill="white"/>'+image(431,3,52))
render(Path('windows/installer/wizard-small.bmp'),55,55,'<rect width="55" height="55" fill="white"/>'+image(0,0,55))
render(Path('linux/packaging/installer-welcome.png'),660,180,'<rect width="660" height="180" fill="url(#bg)"/>'+image(35,36,108)+label(165,85,30,'Marker',weight=600)+label(166,116,14,'让灵感，自在落笔。','#607285')+label(166,143,12,'A little space for your next idea.','#607285'))
