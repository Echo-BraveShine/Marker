from pathlib import Path
import urllib.request,concurrent.futures,hashlib,json,unicodedata
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools import subset
root=Path(__file__).resolve().parents[2];cache=root/'build/export-font-sources';cache.mkdir(exist_ok=True);output=root/'assets/export/fonts'
urls={
 'NotoSans-Regular.ttf':'https://raw.githubusercontent.com/notofonts/noto-fonts/main/hinted/ttf/NotoSans/NotoSans-Regular.ttf',
 'NotoSans-Bold.ttf':'https://raw.githubusercontent.com/notofonts/noto-fonts/main/hinted/ttf/NotoSans/NotoSans-Bold.ttf',
 'NotoSansSC-Variable.ttf':'https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf',
}
def fetch(item):
 name,url=item;p=cache/name
 if not p.exists():p.write_bytes(urllib.request.urlopen(url,timeout=90).read())
 return name,{'url':url,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:sources=dict(executor.map(fetch,urls.items()))
notices=[]
for family in ['Latin','CJK']:
 for style,weight in [('Regular',400),('Bold',700)]:
  font=TTFont(cache/('NotoSans-'+style+'.ttf' if family=='Latin' else 'NotoSansSC-Variable.ttf'))
  notices.append(font['name'].getDebugName(0) or '')
  if family=='CJK':font=instantiateVariableFont(font,{'wght':weight},inplace=True)
  font.recalcTimestamp=False
  cmap=font.getBestCmap()
  # Compatibility aliases otherwise cause PDF readers to copy radical codepoints.
  removed=set()
  for cp,glyph in cmap.items():
   normalized=unicodedata.normalize('NFKC',chr(cp))
   if len(normalized)==1 and normalized!=chr(cp) and cmap.get(ord(normalized))==glyph:removed.add(cp)
  for table in font['cmap'].tables:
   if table.isUnicode():
    for cp in removed:table.cmap.pop(cp,None)
  if family=='CJK':
   wanted=[cp for cp in font.getBestCmap() if 0x2E80<=cp<=0xD7AF or 0xF900<=cp<=0xFFEF or 0x20000<=cp<=0x2FA1F]
   sub=subset.Subsetter();sub.populate(unicodes=wanted);sub.subset(font)
  for key in ['STAT']:
   if key in font:del font[key]
  full='Marker Export '+family
  for record in font['name'].names:
   value={1:full,2:style,4:full+' '+style,6:'MarkerExport'+family+'-'+style,16:full,17:style}.get(record.nameID)
   if value is not None:record.string=value.encode(record.getEncoding(),errors='replace')
  font['OS/2'].usWeightClass=weight
  font['OS/2'].fsSelection=(font['OS/2'].fsSelection & ~0x61) | (0x20 if weight==700 else 0x40)
  font['head'].macStyle=(font['head'].macStyle & ~3) | (1 if weight==700 else 0)
  font.flavor='woff2';path=output/f'Marker{family}-{style}.woff2';font.save(path)
  print(path.name,path.stat().st_size,flush=True)
license=(root/'assets/fonts/OFL-NotoSansSC.txt').read_text();license=license[license.index('SIL OPEN FONT LICENSE'):]
(root/'assets/export/marker-fonts-OFL.txt').write_text('\n\n'.join(dict.fromkeys(notices))+'\n\nExport faces are static Noto derivatives with distinct family names and normalized cmap aliases.\n\n'+license)
(root/'assets/export/font-sources.json').write_text(json.dumps(sources,indent=2)+'\n')
