# Font licenses and store distribution

Audited bundled assets on 2026-11-27. This is a technical license inventory, not a guarantee of store approval or an exhaustive legal opinion.

| Bundled font | Origin | License / bundled notice |
| --- | --- | --- |
| NotoSansSC.ttf | Google Fonts / Adobe Noto Sans SC; static derivative | SIL OFL 1.1, `assets/fonts/OFL-NotoSansSC.txt` |
| NotoSansKR.ttf | Google Fonts / Adobe Noto Sans KR; renamed static subset | SIL OFL 1.1, `assets/fonts/OFL-NotoSansKR.txt` |
| MarkerSans-Regular/Bold.ttf | Renamed Noto Latin export derivatives | SIL OFL 1.1, `assets/export/marker-fonts-OFL.txt` |
| MarkerLatin / MarkerCJK export WOFF2 | Renamed Noto derivatives | SIL OFL 1.1, `assets/export/marker-fonts-OFL.txt` |
| MarkerKorean export WOFF2 | Renamed Noto Sans KR static subsets | SIL OFL 1.1, `assets/fonts/OFL-NotoSansKR.txt` |
| KaTeX export WOFF2 | KaTeX / MathJax fonts | SIL OFL 1.1, `assets/export/katex-fonts-LICENSE.txt` |
| Cupertino icon font | `cupertino_icons` package | MIT; package notice is included by Flutter's dependency license collection |

These OFL fonts can be bundled with free or paid applications and used in exported documents. Keep copyright notices and complete licenses, keep derivative font software under OFL, and do not sell the fonts on their own. The Noto notices reserve **Source**; audited Noto derivative family/PostScript names do not use that reserved name. KaTeX fonts retain their upstream names and are distributed unchanged. A different filename alone does not satisfy renaming requirements: inspect internal names when modifying fonts.

The listed custom notices are declared Flutter assets (including the `assets/export/` directory). Standalone HTML exports also embed the applicable font notices in their third-party metadata. Keep these resources when changing release packaging.

SF Pro, PingFang, Segoe UI, Menlo, Cascadia Code and platform emoji families are runtime system-font references, not proprietary font files copied into this repository or exported documents. Do not add downloaded Apple/Microsoft font files to Android, Linux, Windows, web or export bundles without separately verifying their licenses. Offline exports use the bundled OFL faces.

For future font replacements, record the exact source, preserve notices, inspect Reserved Font Names and internal names, and verify the final store artifact still contains the license resources. This inventory covers fonts; store review, app names, logos and other third-party assets require separate checks.

Official references: [OFL license](https://openfontlicense.org/), [using OFL fonts](https://openfontlicense.org/how-to-use-ofl-fonts), [modifying and redistributing OFL fonts](https://openfontlicense.org/how-to-modify-ofl-fonts/).
