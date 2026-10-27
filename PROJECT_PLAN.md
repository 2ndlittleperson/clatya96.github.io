# Portfolio Website — Project Plan

**Owner:** Jiyoung Yun (윤지영)
**Source:** [Notion portfolio](https://salty-morning-69c.notion.site/Jiyoung-Yun-379c9a728c5c80dd8ed8c449607e94e6)
**Target:** `https://clatya96.github.io/`
**Date:** 2026-10-27

---

## 1. Goal

Rebuild the existing Notion portfolio as a self-owned static website hosted on GitHub Pages.

Why move off Notion:

| | Notion site | GitHub Pages site |
|---|---|---|
| URL | `salty-morning-69c.notion.site/Jiyoung-Yun-379c…` | `clatya96.github.io` |
| Load time | ~2–4s (JS-rendered) | <0.5s (static HTML) |
| Branding | "Powered by Notion" footer | none |
| Custom domain | paid plan only | free |
| SEO / Google Scholar | poor (client-rendered) | full (server-rendered HTML + JSON-LD) |
| Cost | — | free |

**The content does not change.** Every paragraph, date, citation and link is carried over from the Notion page verbatim. This is a re-platforming, not a rewrite.

---

## 2. Content inventory (extracted from Notion)

The Notion page is JavaScript-rendered, so a plain page fetch returns nothing. Content was retrieved through Notion's public `loadPageChunk` API and parsed block-by-block. Full structure found:

```
Jiyoung Yun
├── ENG
│   ├── ABOUT ME   — About, Education & Work, Publication, Teaching Experience, Contact
│   ├── FEATURED   — 2 publication cards (image + citation + external link)
│   └── CV         — CV_JiyoungYun_ETH.pdf
└── KOR
    ├── ABOUT ME   — same sections, Korean copy
    ├── FEATURED   — "Featured Publications", same 2 cards
    └── CV         — same PDF
```

### 2.1 About (4 paragraphs)

Carried over verbatim in both languages. Covers: introduction; B.F.A. at Sungkyunkwan University → M.S. at KAIST → User Researcher at KRAFTON; the scope of the work (user research for KRAFTON studios in the United States, Sweden, Spain, and South Korea; developing qualitative and quantitative game user research methodologies using eye tracking and behavioral data); and the current research interest in improving AI assistance through gaze, task context, and user feedback while preserving users' sense of control.

### 2.2 Education & Work (6 entries)

| Years | Entry |
|---|---|
| 2024 – present | **User Researcher, KRAFTON** — user research and methodology development |
| 2024 – 2024 | **UX Researcher, NCSOFT** — UX analysis for game products |
| 2021 – 2024 | **M.S. in Cultural Technology, KAIST** — IBD Lab, advisor Prof. Jihyeon Lee. Thesis: *Relationship between trustworthy museum Instagram post cues and museum brand attitudes: a focus on users in their 20s* |
| 2020 – 2021 | **Research Internship, Sungkyunkwan University** — HAI Lab, advisor Prof. Hayeon Song |
| 2015 – 2021 | **B.F.A. & Media Arts (double major), Sungkyunkwan University** |
| 2016 – 2016 | **Curatorial Internship, uJung Art Center** |

### 2.3 Publications (6 entries)

| Date | Role | Citation |
|---|---|---|
| 2022.04 | 2nd author | Lee, S., **Yun, J.**, Lee, S., Song, Y., & Song, H. *Will AI image synthesis technology help constructivist education at the online art museum?* CHI EA '22 |
| 2022.10 | co-1st author | Lee, S. U., **Yun, J.**, Kim, D., Kim, D., Oh, S. Y., & Yoon, S. H. *CARDS: Comprehensive AR Docent System.* ISMAR-Adjunct 2022, IEEE |
| 2022.10 | co-1st author | Kim, B. W., Park, J., & **Yun, J.** *Metaverse communication channel to enhance comradery of telecommuter.* HCI KOREA 2023 |
| 2023.06 | 5th author | Pyo, H., Lee, G., Kim, G., Lee, J., **Yun, J.**, & Lee, J. *Dynamic community detection based on temporal behavior data in virtual conferences.* KCC 2023 |
| 2023.09 | 1st author | **Yun, J. Y.**, & Lee, J. H. *Analysis of museum social media posts for effective social media management.* Cultural Space on Metaverse, Springer |
| 2023.09 | 3rd author | Lee, G. B., Chang, M., **Yun, J. Y.**, & Lee, J. H. *Spatial behavior data in virtual conference: proximity and network analysis.* Cultural Space on Metaverse, Springer |

The two Korean-language papers (HCI KOREA 2023, KCC 2023) keep their Korean titles on the Korean page and the English titles on the English page, exactly as Notion does.

### 2.4 Featured (2 cards)

1. **CARDS: Comprehensive AR Docent System** — ISMAR-Adjunct 2022 → [IEEE Xplore](https://ieeexplore.ieee.org/abstract/document/9974452)
2. **Will AI Image Synthesis Technology Help Constructivist Education at The Online Art Museum?** — CHI EA '22 → [ACM DL](https://dl.acm.org/doi/10.1145/3491101.3519788)

### 2.5 Teaching

2023 Spring — Teaching Assistant, Creative Experiment Practice, KAIST

### 2.6 Contact

`clatya96@gmail.com`

> Note: the Notion English page *displays* `clatya96@gmail.com` but its link actually points to `clatya96@krafton.com`. On the new site both the visible text and the link are `clatya96@gmail.com`.

### 2.7 Assets

| File | Source | Status |
|---|---|---|
| `profile.jpg` | Notion attachment `10a5205a…` | downloaded, re-encoded 311 KB PNG → 28 KB JPEG ✓ |
| `featured-cards.jpg` | Notion attachment `94f5e105…` | downloaded, 157 KB PNG → 37 KB JPEG ✓ |
| `featured-chi.jpg` | Notion attachment `c8e6702d…` | downloaded, 1.04 MB PNG → 109 KB JPEG ✓ |
| `CV_JiyoungYun.pdf` | `CV_JiyoungYun_ETH.pdf` | needs a signed URL — tested and working ✓ |

---

## 3. Confirmed decisions

| Decision | Choice | Reason |
|---|---|---|
| Tech stack | **Plain HTML / CSS / JS** | No build step, no npm, no dependencies. Push and it's live. Easiest to edit by hand years from now. |
| Languages | **English + Korean, with an EN \| KO toggle** | Mirrors the Notion site. |
| Design | **Minimal academic** | Serif headings, generous whitespace, two-column timeline. Standard for researcher portfolios. |
| Contact email | `clatya96@gmail.com` | Personal address, for a personal portfolio. |
| Hosting | **User site** — repo `clatya96.github.io` | Clean root URL, no `/portfolio/` subpath. |

### Not chosen, and why

- **Jekyll** — content would live in Markdown + YAML, which is tidier for long publication lists, but it needs Ruby to preview locally and adds a layer between you and the page.
- **Astro / Next.js** — more powerful, but requires Node, a build step, and a GitHub Actions deploy workflow. Overkill for a six-section portfolio.

Either remains an easy migration later; the content is in plain HTML, not locked in a proprietary format.

---

## 4. File structure

```
Github_website/
├── PROJECT_PLAN.md          this document
├── README.md                how to deploy and edit
├── index.html               English page
├── ko/
│   └── index.html           Korean page
├── css/
│   └── style.css            single stylesheet
├── js/
│   └── main.js              ~40 lines: theme toggle + scroll-spy
├── assets/
│   ├── profile.jpg
│   ├── featured-cards.jpg
│   ├── featured-chi.jpg
│   └── CV_JiyoungYun.pdf
├── favicon.svg              297-byte inline SVG mark
├── .nojekyll                tells GitHub Pages to serve files as-is
└── .gitignore
```

No `package.json`. No CI workflow. GitHub Pages serves the `main` branch root directly.

---

## 5. Page specification

### 5.1 Layout

```
┌──────────────────────────────────────┐
│  Jiyoung Yun          EN | KO   ☾    │  sticky header
│  About  Featured  CV                 │
├──────────────────────────────────────┤
│  ┌────────┐                          │
│  │ photo  │   Hi, my name is          │
│  │        │   Jiyoung Yun.            │
│  └────────┘                          │
│                                      │
│  …four bio paragraphs…               │
│                                      │
│  EDUCATION & WORK                    │
│  ──────────────────────────────      │
│  2024 – present   User Researcher,   │
│                   KRAFTON            │
│  2024 – 2024      UX Researcher,     │
│                   NCSOFT             │
│  …                                   │
│                                      │
│  PUBLICATIONS                        │
│  ──────────────────────────────      │
│  2022.04          Lee, S., Yun, J.,  │
│  2nd author       … CHI EA '22       │
│  …                                   │
│                                      │
│  FEATURED                            │
│  ──────────────────────────────      │
│  ┌──────┐  CARDS: Comprehensive      │
│  │ img  │  AR Docent System          │
│  └──────┘  ISMAR 2022 · 🔗 Link      │
│                                      │
│  TEACHING                            │
│  CONTACT   clatya96@gmail.com        │
│  CV        [ Download CV (PDF) ]     │
└──────────────────────────────────────┘
```

Single scrolling page per language, with anchor navigation — the Notion tabs become sections.

### 5.2 Behaviour

- **Responsive** — mobile-first. The year/detail timeline is a CSS grid that collapses to a stacked single column below 640px. Nothing overflows horizontally at 375px.
- **Dark mode** — follows the OS setting by default, with a manual toggle saved to `localStorage`. An inline script in `<head>` applies the theme before first paint so there is no white flash.
- **Works without JavaScript** — all content is in the HTML. JS only adds the theme toggle and active-section highlighting.
- **Korean typography** — `word-break: keep-all` so Korean lines wrap between words, not mid-word.
- **Accessibility** — semantic landmarks, a skip link, visible focus rings, alt text on every image, and `prefers-reduced-motion` respected.
- **Print** — a print stylesheet so the page prints as a clean CV-like document.

### 5.3 SEO / discoverability

Each page carries a title and meta description, Open Graph + Twitter card tags (preview image `profile.jpg`), reciprocal `hreflang` links between the English and Korean versions, and JSON-LD `Person` structured data (name, job title, KRAFTON, KAIST, Sungkyunkwan, email) so search engines and Google Scholar parse the page correctly.

---

## 6. Deployment

The site is built and committed locally. Three steps remain, which you do:

1. **Create the repository** — go to <https://github.com/new>, name it exactly `clatya96.github.io`, set it **Public**, and add **no** README, `.gitignore`, or license.
2. **Push**
   ```bash
   cd C:\Users\clatya96\Projects\Github_website
   git push -u origin main
   ```
3. **Enable Pages** — repo *Settings* → *Pages* → Source: **Deploy from a branch** → `main` / `/ (root)` → *Save*.

After about a minute the site is live at <https://clatya96.github.io/> (Korean at `/ko/`). Every later `git push` redeploys automatically.

A custom domain (e.g. `jiyoungyun.com`) can be added later with a `CNAME` file plus a DNS record — see README.

---

## 7. Maintenance

| To change | Edit |
|---|---|
| Bio text | `index.html` **and** `ko/index.html`, `#about` section |
| Add a job or degree | both files, `#education` timeline |
| Add a publication | both files, `#publications` list |
| Colours, fonts, spacing | `css/style.css` (variables at the top) |
| CV | replace `assets/CV_JiyoungYun.pdf`, keeping the filename |

Content lives in two files because each language page is standalone HTML — that is what keeps both pages indexable and readable without JavaScript. The trade-off is that text edits must be made twice.

---

## 8. Open items

- **Profile photo** — carried over at Notion's resolution. Replacing `assets/profile.jpg` with a higher-resolution version is a drop-in swap.
- **CV file** — the Notion file is named `CV_JiyoungYun_ETH.pdf`, which looks like an ETH Zürich application version. Say if a different or newer CV should be used.
- **Custom domain** — not configured.
- **Google Scholar / ORCID / LinkedIn links** — not on the Notion page. Easy to add to the contact section if wanted.
