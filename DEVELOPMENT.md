# Development Document

How the portfolio site will be built, file by file. Read alongside [`PROJECT_PLAN.md`](PROJECT_PLAN.md), which covers *what* is being built and why; this document covers *how*.

**Status:** built and verified locally; committed but **not pushed**. See §7 for verification results and §5 for the remaining deploy steps.

---

## 1. Architecture

### 1.1 The one decision everything follows from

**No build step.** The files in this repository are the files the browser receives. There is no compiler, bundler, package manager, or CI pipeline between the source and the live site.

Consequences, good and bad:

| | |
|---|---|
| ✅ | Editing content means opening an `.html` file and typing. No toolchain to install or keep working. |
| ✅ | Nothing to break. No `npm audit` warnings, no dependency that goes stale in two years, no lockfile. |
| ✅ | Deploy is `git push`. GitHub Pages serves the branch root as-is. |
| ✅ | Previewing locally needs only `python -m http.server`. |
| ❌ | The English and Korean pages each contain a full copy of the markup, so a structural change is made twice. |
| ❌ | No templating: adding a publication means copy-pasting a `<li>` block rather than adding a row to a YAML file. |

The duplication is the real cost. It is accepted because the content is small and stable (6 jobs/degrees, 6 publications, 2 featured cards) and because the alternative — generating the pages from data — means a build step, which means a toolchain, which is the thing being avoided. §6.2 describes a mitigation.

### 1.2 Rendering model

Every piece of content is in the HTML source. JavaScript is **progressive enhancement only**: the theme toggle and the active-section highlight. With JS disabled the site is fully readable and navigable.

This matters specifically for an academic portfolio: Google Scholar, ORCID, institutional crawlers, and link previews on Slack/Twitter/LinkedIn all read raw HTML and generally do not execute JavaScript. The Notion site fails this test — that is why a plain fetch of the Notion URL returns nothing but the word "Notion" (see §3.1). The new site must not inherit that flaw.

### 1.3 Two pages, not one page with a language switcher

A JS-driven language switch on a single page would halve the duplication, but:

- Both languages would be in the DOM at once, so search engines see a page that is half Korean and half English.
- There would be no distinct URL for the Korean version, so `hreflang` could not work and the Korean page could not be linked or shared directly.
- Without JS, both languages would render stacked on top of each other.

So: `/` is English, `/ko/` is Korean, each a standalone document, cross-linked with reciprocal `hreflang` tags.

---

## 2. Directory layout

```
Github_website/
├── PROJECT_PLAN.md          plan + content inventory (already written)
├── DEVELOPMENT.md           this document
├── README.md                deploy + edit instructions
│
├── index.html               English page
├── ko/
│   └── index.html           Korean page
│
├── css/
│   └── style.css            single stylesheet, 437 lines
├── js/
│   └── main.js              117 lines
│
├── assets/                                                      ✅ downloaded
│   ├── profile.jpg          512×512, 28 KB
│   ├── featured-cards.jpg   550×317, 37 KB
│   ├── featured-chi.jpg     900×885, 109 KB
│   └── CV_JiyoungYun.pdf    104 KB
│
├── favicon.svg              inline SVG mark, 297 bytes
├── .nojekyll                empty file
└── .gitignore
```

Three directories (`css/`, `js/`, `assets/`) rather than flat files, so the root stays readable as the repository grows.

### 2.1 Why `.nojekyll`

GitHub Pages runs every pushed site through Jekyll by default. Jekyll ignores files and directories beginning with `_` and will attempt to interpret `{{ }}` and `{% %}` sequences in HTML as template syntax. An empty `.nojekyll` file at the root disables that and makes Pages a plain static file server. It costs nothing and removes a whole category of confusing future bugs.

---

## 3. Assets — already retrieved

### 3.1 How the content was extracted

Notion public sites render entirely client-side; fetching the page URL returns an empty shell. The content was retrieved through Notion's internal-but-public API:

```bash
curl -X POST 'https://salty-morning-69c.notion.site/api/v3/loadPageChunk' \
  -H 'Content-Type: application/json' \
  -d '{"pageId":"379c9a72-8c5c-80dd-8ed8-c449607e94e6","limit":200,
       "cursor":{"stack":[]},"chunkNumber":0,"verticalColumns":false}'
```

This returns a `recordMap` of blocks, which was walked recursively to reconstruct the page tree. Two subtrees (the `KOR` tab and the `CV` tab) are lazy-loaded and were fetched with separate calls using their block IDs. The reconstructed tree is in [`PROJECT_PLAN.md` §2](PROJECT_PLAN.md); the verbatim text is in the appendix of this document (§8).

This was a one-time extraction. The finished site has no dependency on Notion.

### 3.2 Asset download and verification

Images came from the public image endpoint:

```
https://salty-morning-69c.notion.site/image/<url-encoded-attachment-id>?table=block&id=<block-id>&cache=v2
```

The CV PDF is not served by that endpoint (it returns an HTML page with HTTP 200 — a silent failure that a status-code check would miss). It required a signed URL:

```bash
curl -X POST '…/api/v3/getSignedFileUrls' -H 'Content-Type: application/json' \
  -d '{"urls":[{"url":"attachment:796f889d-…:CV_JiyoungYun_ETH.pdf",
      "permissionRecord":{"table":"block","id":"404c9a72-8c5c-80e2-ab89-d2f60093bce2"}}]}'
```

All four files were verified by **magic bytes**, not HTTP status:

| File | Bytes | Magic | Verdict |
|---|---|---|---|
| `profile.png` → `profile.jpg` | 311,322 → 28,227 | `89 50 4E 47` → `FF D8 FF` | valid, re-encoded ✅ |
| `featured-cards.png` → `.jpg` | 156,544 → 37,356 | `89 50 4E 47` → `FF D8 FF` | valid, re-encoded ✅ |
| `featured-chi.png` → `.jpg` | 1,040,166 → 109,302 | `89 50 4E 47` → `FF D8 FF` | valid, re-encoded ✅ |
| `CV_JiyoungYun.pdf` | 106,507 | `%PDF-` | valid PDF ✅ |

### 3.3 Asset work performed

PNG was the wrong container for three photographic figures. Re-encoding to progressive JPEG at quality 82–86 cut the image payload from **1.51 MB to 175 KB (-88%)** with no visible loss at display size:

| File | Before | After | Change |
|---|---|---|---|
| `profile.jpg` | 311,322 (512×512 PNG) | 28,227 (512×512 JPEG q86) | −91% |
| `featured-cards.jpg` | 156,544 (550×317 PNG) | 37,356 (550×317 JPEG q82) | −76% |
| `featured-chi.jpg` | 1,040,166 (1050×1033 PNG) | 109,302 (900×885 JPEG q82) | −89% |

An intermediate attempt that only downscaled and re-optimised the PNGs left `featured-chi` at 683 KB — still far over budget. Both featured images are paper figures (photographs and screenshots on white), which is exactly the content PNG compresses badly and JPEG compresses well. `profile.jpg` is kept at its native 512×512 rather than downscaled, since at 28 KB the extra resolution is effectively free and it covers retina displays at the 152 px render size.

The originals were re-fetched from Notion for the conversion rather than re-encoding the already-downscaled PNGs, so there is only one lossy generation.
- The CV keeps the filename `assets/CV_JiyoungYun.pdf` so that replacing it later is a drag-and-drop with no HTML edit. (The Notion original is `CV_JiyoungYun_ETH.pdf`; the `_ETH` suffix is dropped as it looks application-specific.)

---

## 4. File-by-file specification

### 4.1 `index.html`

#### Document head

```html
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <title>Jiyoung Yun — User Researcher</title>
  <meta name="description" content="Jiyoung Yun is a user researcher at KRAFTON
        working on game user research methodology, eye tracking, and behavioral data.">

  <link rel="canonical" href="https://clatya96.github.io/">
  <link rel="alternate" hreflang="en" href="https://clatya96.github.io/">
  <link rel="alternate" hreflang="ko" href="https://clatya96.github.io/ko/">
  <link rel="alternate" hreflang="x-default" href="https://clatya96.github.io/">

  <!-- Open Graph / Twitter card … -->
  <!-- JSON-LD Person schema … -->

  <script>/* inline theme bootstrap — see §4.3 */</script>
  <link rel="stylesheet" href="css/style.css">
</head>
```

Three head details worth calling out:

1. **`hreflang` must be reciprocal.** Each page declares both itself and its counterpart, plus `x-default`. If only one direction is declared, search engines ignore the relationship entirely.
2. **The theme bootstrap is inline and before the stylesheet**, so `data-theme` is set before first paint. Loading it as an external script would produce a white flash on dark-mode devices.
3. **JSON-LD `Person` schema** — name, `jobTitle`, `worksFor` KRAFTON, `alumniOf` KAIST and Sungkyunkwan, `email`, `knowsAbout`. This is what makes a name search surface the page correctly instead of guessing from body text.

#### Body structure

```html
<body>
  <a class="skip-link" href="#main">Skip to content</a>

  <header class="site-header">
    <a class="site-header__name" href="#main">Jiyoung Yun</a>
    <nav class="site-nav" aria-label="Sections">
      <a href="#about">About</a>
      <a href="#education">Education &amp; Work</a>
      <a href="#publications">Publications</a>
      <a href="#featured">Featured</a>
      <a href="#contact">Contact</a>
    </nav>
    <div class="site-header__tools">
      <p class="lang-switch">
        <span aria-current="true">EN</span>
        <a href="ko/" hreflang="ko" lang="ko">KO</a>
      </p>
      <button class="theme-toggle" type="button"
              aria-label="Switch to dark theme" aria-pressed="false">☾</button>
    </div>
  </header>

  <main id="main">
    <section id="about"        aria-labelledby="about-h">        … </section>
    <section id="education"    aria-labelledby="education-h">    … </section>
    <section id="publications" aria-labelledby="publications-h"> … </section>
    <section id="featured"     aria-labelledby="featured-h">     … </section>
    <section id="teaching"     aria-labelledby="teaching-h">     … </section>
    <section id="contact"      aria-labelledby="contact-h">      … </section>
  </main>

  <footer class="site-footer"> … </footer>
  <script src="js/main.js" defer></script>
</body>
```

Notes:

- The current language in the switch is a `<span>`, not an `<a href="#">` — a link to the page you are already on is noise for screen readers. `aria-current` marks it.
- Every `<section>` is labelled by its own heading via `aria-labelledby`, which gives screen-reader users a navigable landmark list matching the visible nav.
- `defer` on the script, not `async`: it must run after the DOM is parsed, and it is not time-critical.

#### Section markup

**About** — a two-column flex that stacks on mobile. The profile image carries real alt text, `width`/`height` attributes to reserve layout space (preventing content shift as it loads), and `loading="eager"` since it is above the fold.

```html
<section id="about" aria-labelledby="about-h">
  <h1 id="about-h" class="visually-hidden">About Jiyoung Yun</h1>
  <div class="about">
    <img class="about__photo" src="assets/profile.jpg"
         alt="Portrait of Jiyoung Yun" width="320" height="320" loading="eager">
    <div class="about__text">
      <p class="lede">Hi, my name is Jiyoung Yun.</p>
      <p>After receiving my Bachelor of Fine Arts from Sungkyunkwan University
         and a Master's degree from KAIST, I am currently working as a user
         researcher at <a href="https://krafton.com">KRAFTON</a>.</p>
      <p>…</p>
    </div>
  </div>
</section>
```

> One content fix: Notion links the word "KRAFTON" to `krafton.com` with no scheme, which browsers resolve as a *relative* path — the link is broken on the Notion site. It becomes `https://krafton.com` here.

**Education & Work** — a description list, which is the semantically correct element for date → entry pairs, styled as a two-column grid.

```html
<dl class="timeline">
  <dt>2024 &ndash; present</dt>
  <dd>
    <strong>User Researcher, KRAFTON</strong>
    <span>Responsible for user research and developing methodologies</span>
  </dd>
  …
</dl>
```

Six entries, newest first, exactly as in the Notion source. The KAIST entry carries its thesis title in `<cite>` and the lab/advisor line; the Sungkyunkwan internship carries its lab/advisor line.

**Publications** — an ordered list, newest last to match Notion's order, each entry pairing a date + authorship-position label with the full citation. Jiyoung Yun's name is `<strong>` in each author list so her position is scannable. Where the Notion page has a link (CHI 2022, ISMAR 2022) the title links out; the other four have no link in the source and get none invented.

```html
<ol class="pubs" reversed>
  <li class="pub">
    <p class="pub__meta"><time datetime="2022-04">2022.04</time>
       <span class="pub__role">2nd author</span></p>
    <p class="pub__cite">Lee, S., <strong>Yun, J.</strong>, Lee, S., Song, Y., &amp;
       Song, H. (2022, April). <cite>Will AI image synthesis technology help
       constructivist education at the online art museum?</cite> In
       <em>CHI Conference on Human Factors in Computing Systems Extended
       Abstracts</em> (pp. 1&ndash;7).
       <a href="https://dl.acm.org/doi/10.1145/3491101.3519788">ACM DL</a></p>
  </li>
  …
</ol>
```

**Featured** — two cards, image + title + venue/author line + external link. Images get `loading="lazy"` (below the fold) and explicit dimensions.

**Teaching**, **Contact** — short sections. Contact is `<a href="mailto:clatya96@gmail.com">clatya96@gmail.com</a>`, resolving the Notion mismatch where the visible text said `@gmail.com` but the link pointed at `@krafton.com`. The CV download sits here as a button-styled link with `type="application/pdf"` and a visible "(PDF, 104 KB)" hint, so a click is never a surprise.

### 4.2 `ko/index.html`

Structurally identical. Differences:

| | English | Korean |
|---|---|---|
| `<html lang>` | `en` | `ko` |
| Paths | `css/style.css` | `../css/style.css` |
| Language switch | `EN` current, link to `ko/` | link to `../`, `KO` current |
| Nav labels | About, Education & Work… | 소개, 학력 및 경력, 연구 실적, 주요 연구, 연락처 |
| Authorship labels | 2nd author, co-1st author… | 2저자, 공동 1저자… |
| Korean-language paper titles | English titles | Korean titles (HCI KOREA 2023, KCC 2023) |
| Advisor names | Prof. Jihyeon Lee / Prof. Hayeon Song | 지도교수: 이지현 / 송하연 |

Body copy is the verbatim Korean from the Notion KOR tab (§8.2) — not a translation of the English, since the two differ slightly in the source and the Korean is the author's own wording.

The relative paths are the easiest thing to get wrong here. `ko/index.html` is one level deep, so every reference to `css/`, `js/`, and `assets/` needs a `../` prefix. Verification step V2 (§7) exists specifically to catch this.

### 4.3 `css/style.css`

One stylesheet, no framework, no reset library — a short normalize block instead (`box-sizing: border-box`, margin reset, `img { max-width: 100% }`).

#### Design tokens

Everything visual is a custom property at the top of the file, so colour and type changes happen in one place:

```css
:root {
  /* type */
  --font-display: ui-serif, Georgia, "Noto Serif KR", serif;
  --font-body:    system-ui, -apple-system, "Pretendard", "Noto Sans KR", sans-serif;
  --step--1: clamp(0.84rem, 0.80rem + 0.18vw, 0.92rem);
  --step-0:  clamp(1.00rem, 0.96rem + 0.22vw, 1.12rem);
  --step-1:  clamp(1.25rem, 1.15rem + 0.50vw, 1.50rem);
  --step-2:  clamp(1.60rem, 1.40rem + 1.00vw, 2.25rem);

  /* spacing — 4px base scale */
  --space-xs: .5rem;  --space-s: 1rem;   --space-m: 1.75rem;
  --space-l:  3rem;   --space-xl: 5rem;

  /* colour — light */
  --bg: #fdfdfc;  --surface: #f4f3f0;  --text: #1c1b19;
  --muted: #6b6760;  --rule: #e2e0da;  --accent: #7a5c3e;

  --measure: 46rem;   /* ~72 characters */
}

:root[data-theme="dark"] {
  --bg: #16181a;  --surface: #1f2224;  --text: #e8e6e3;
  --muted: #9a958d;  --rule: #2e3234;  --accent: #c9a77c;
}
```

Fluid `clamp()` type means no font-size media queries: the scale interpolates smoothly between mobile and desktop.

The serif/sans pairing (serif headings, sans body) is the minimal-academic convention and reads as considered rather than default. `Noto Serif KR` / `Noto Sans KR` / `Pretendard` are listed as fallbacks so Korean renders in a matching face where available — **no webfonts are loaded**, so there is no render-blocking request and no Google Fonts privacy issue. The trade-off is that typography varies slightly across platforms, which is the right trade for a text site that must load instantly.

#### Layout

- `.wrap { max-inline-size: var(--measure); margin-inline: auto; }` — one centring utility.
- Timeline as a grid, collapsing at the single breakpoint:

  ```css
  .timeline { display: grid; grid-template-columns: 10rem 1fr; gap: var(--space-xs) var(--space-m); }
  @media (max-width: 40em) {
    .timeline { grid-template-columns: 1fr; }
    .timeline dt { font-size: var(--step--1); color: var(--muted); }
    .timeline dd { margin-block-end: var(--space-m); }
  }
  ```

- Featured cards use `grid-template-columns: minmax(0, 15rem) 1fr`, stacking under the same breakpoint. The `minmax(0, …)` matters: without it a wide image can blow out the grid track and cause horizontal overflow.
- **One breakpoint only** (`40em`). Multiple breakpoints are where responsive CSS rots; fluid type and `minmax()` handle the rest.

#### Korean typography

```css
:lang(ko) { word-break: keep-all; overflow-wrap: break-word; line-height: 1.8; }
```

`word-break: keep-all` stops Korean breaking mid-word (the browser default for CJK is to break anywhere), and the looser line-height compensates for Hangul's larger visual density. `overflow-wrap: break-word` is the escape hatch so a long unbreakable string still cannot cause horizontal scroll. Applied via `:lang(ko)` rather than a class, so it works on the Korean page *and* on any inline Korean in the English page.

#### Theme, motion, print

```css
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { /* dark tokens */ } }
@media (prefers-reduced-motion: reduce) { *, *::before, *::after {
  animation-duration: .01ms !important; transition-duration: .01ms !important;
  scroll-behavior: auto !important; } }
@media print { .site-header, .theme-toggle, .lang-switch { display: none }
  a[href^="http"]::after { content: " (" attr(href) ")"; font-size: .8em } }
```

The dark-mode selector is `:root:not([data-theme="light"])` so an explicit light choice beats the OS preference — the toggle must win over the system setting, not fight it.

The print block hides chrome and expands link URLs inline, so a printed copy functions as a CV handout.

#### Accessibility details in CSS

- `.visually-hidden` — the clip-rect pattern, for headings that must exist for structure but not for sight.
- `.skip-link` — off-screen until `:focus`.
- `:focus-visible { outline: 2px solid var(--accent); outline-offset: 3px }` — never `outline: none`.
- All colour pairs targeted at **WCAG AA (4.5:1)** in both themes, checked during verification rather than assumed.

### 4.4 `js/main.js`

Two features, no dependencies, roughly 45 lines.

**Theme toggle.** A tiny inline bootstrap runs in `<head>` before paint:

```html
<script>
  try {
    var t = localStorage.getItem("theme");
    if (t) document.documentElement.dataset.theme = t;
  } catch (e) {}
</script>
```

`try/catch` because `localStorage` throws in Safari private browsing and in sandboxed iframes — an uncaught error here would block the rest of the page. The deferred `main.js` then wires the button, flips `data-theme`, writes `localStorage`, and keeps `aria-pressed` and `aria-label` in sync so the control is meaningful to a screen reader.

**Scroll-spy.** `IntersectionObserver` with `rootMargin: "-45% 0px -50% 0px"` marks the section nearest the viewport's middle and sets `aria-current="location"` on the matching nav link. CSS styles that attribute — so if JS never runs, the nav simply has no highlight and nothing looks broken. `IntersectionObserver` is used rather than a `scroll` listener because it does not run layout-reading code on every scroll frame.

Both features are wrapped so a failure in one cannot break the other.

### 4.5 `README.md`

Written for the repository owner returning in six months with no context:

1. What this is and where it is live.
2. **Local preview** — `python -m http.server 8000`, then `http://localhost:8000/`. Includes the warning that opening `index.html` by double-clicking (`file://`) breaks the `/ko/` link and some relative paths; always use the server.
3. **Editing** — a table mapping "the thing you want to change" to "the file and section", with a prominent reminder that body-copy edits must be made in **both** `index.html` and `ko/index.html`.
4. **Replacing the CV** — overwrite `assets/CV_JiyoungYun.pdf`, keep the name, commit.
5. **Deploy** — the four steps in §5.
6. **Custom domain** — add a `CNAME` file containing the bare domain, point a DNS `CNAME` record at `clatya96.github.io`, enable *Enforce HTTPS*, and update the absolute URLs in both `<head>` blocks.

---

## 5. Deployment

The build produces a local git repository with one commit and a configured remote. It is **not** pushed: the GitHub repository does not exist yet, and the `gh` CLI is not installed on this machine (verified), so the repository cannot be created non-interactively.

```bash
git init
git add -A
git commit -m "Initial portfolio site"
git branch -M main
git remote add origin https://github.com/clatya96/clatya96.github.io.git
```

Remaining steps, performed by the owner:

1. Create a repository at <https://github.com/new> named exactly **`clatya96.github.io`**, **Public**, with no README, `.gitignore`, or license. *(The name must match the username exactly, or Pages serves it at a `/subpath` instead of the root.)*
2. `git push -u origin main`
3. *Settings → Pages → Source: Deploy from a branch → `main` / `/ (root)` → Save*
4. Wait ~60 seconds, then open <https://clatya96.github.io/>.

Thereafter every push redeploys automatically. Pages has no build log to read for a static site, so if a page 404s the cause is almost always the repository name or the branch/folder selection in step 3.

---

## 6. Risks and how they are handled

| Risk | Handling |
|---|---|
| **Notion signed URLs expire** | Already moot — all four assets are downloaded and verified locally (§3.2). The site has no runtime dependency on Notion. |
| **EN and KO pages drift apart** | §6.2. |
| **Relative paths break on the Korean page** | Verification step V2 crawls both pages and HTTP-checks every local reference. |
| **`featured-chi.png` was 1 MB** | Resolved: downscaled to 900 px and re-encoded as JPEG, 1,040,166 → 109,302 bytes. |
| **Contrast fails in dark mode** | Contrast ratios computed during verification (V5), not eyeballed. |
| **Repo named wrong → Pages 404** | Called out explicitly in README and §5 step 1, the single most common GitHub Pages mistake. |
| **Publication list grows past what hand-editing tolerates** | §6.3. |

### 6.1 What is explicitly out of scope

No analytics, no cookie banner, no contact form, no comment system, no blog, no search. Each would add either a third-party dependency or a backend, and none are needed by a portfolio whose job is to be read and to make an email address findable.

### 6.2 Keeping the two language pages in sync

Mitigations, in order of how much they are relied on:

1. **Identical structure.** Both files use the same element order, the same class names, and the same section IDs. A diff of the two files shows only text nodes and the three path/lang differences, making drift visible.
2. **A sync check in verification.** V3 parses both files and asserts the same section IDs, the same number of `.timeline` rows, and the same number of `.pub` entries. A publication added to one page and not the other fails this check.
3. **A README note** at the top of the editing section.

This does not make drift impossible; it makes drift *loud*.

### 6.3 The migration path, if it is ever needed

If the publication list grows past ~20 entries, hand-editing two HTML files stops being reasonable. At that point the content moves to a single `_data/publications.yml` and the pages become Jekyll layouts — which GitHub Pages builds natively, so deployment does not change at all. That migration is cheap *because* the markup is semantic and class-named now: the HTML becomes the layout template nearly as-is. Nothing in this plan forecloses it. It is deliberately not done today, because 6 publications do not justify a Ruby toolchain.

---

## 7. Verification plan

Run before declaring the build complete. Each check has a pass condition, not just "look at it".

| | Check | Method | Pass condition |
|---|---|---|---|
| **V1** | Asset integrity | magic bytes + byte size | 3 JPEGs with `FF D8 FF`, 1 PDF with `%PDF`, all non-zero, every image under 150 KB |
| **V2** | No broken local paths | parse both HTML files for `src`/`href`, resolve relative to each file's own directory, stat each | every local reference resolves; catches the missing `../` on `/ko/` |
| **V3** | EN/KO structural parity | parse both, compare section IDs and child counts | same section IDs; equal `.timeline` and `.pub` counts |
| **V4** | Content fidelity | diff rendered text against the §8 appendix | every bio paragraph, all 6 timeline rows, all 6 citations, both featured cards present and verbatim; contact is `clatya96@gmail.com` in **both** the text and the `href` |
| **V5** | Contrast | compute WCAG ratios for every foreground/background token pair, both themes | body text ≥ 4.5:1, muted text ≥ 4.5:1, large headings ≥ 3:1 |
| **V6** | Responsive | serve locally, view at 375 / 768 / 1280 px | no horizontal scroll at 375 px; timeline stacked below 640 px; Korean wraps at word boundaries |
| **V7** | No-JS | disable JavaScript, reload both pages | all content visible, nav anchors work, no layout breakage; only the theme button and nav highlight inert |
| **V8** | External links | HTTP-check KRAFTON, IEEE, ACM | each returns 200 or a 3xx to a live page |
| **V9** | Theme persistence | toggle, reload | theme survives reload with no flash of the wrong theme |
| **V10** | HTML validity | W3C validator or `tidy` | no errors; warnings reviewed |

V2, V3, V5 and V8 are scripted rather than manual — they are the checks a human eye reliably misses. V6, V7 and V9 were driven through the Chrome DevTools Protocol rather than by eye, so the numbers below are measured, not estimated.

### 7.1 Results

All ten passed. Run date 2026-10-27, against `python -m http.server` on `127.0.0.1:8765`.

| | Result |
|---|---|
| **V1** | 3 JPEGs (`FF D8 FF`) + 1 PDF (`%PDF-`). Largest image 109,302 B. Total `assets/` 281 KB. |
| **V2** | 14 local references across both pages, all resolve. |
| **V3** | Identical section IDs, 7 `<dt>`/7 `<dd>`, 6 `.pub`, 2 `.card`, 5 nav links on both pages. |
| **V4** | 36 content assertions pass, including all 6 citations, both bio sets, and `clatya96@gmail.com` in text *and* `href` on both pages, with no `@krafton.com` address anywhere. |
| **V5** | Worst ratio of 14 pairs: **6.22:1** (muted on surface, light). Everything else 6.29–16.91:1. AA requires 4.5:1. |
| **V6** | `scrollWidth === clientWidth` at 375 px and 1280 px, both languages — zero overflowing elements. Timeline stacks below 640 px; Korean breaks at word boundaries. |
| **V7** | 3,752 chars of English and 2,774 chars of Korean visible text with all `<script>` removed. |
| **V8** | KRAFTON 200. IEEE 200, page title confirms *CARDS: Comprehensive AR Docent System*. ACM sits behind a Cloudflare interstitial, so the DOI was confirmed through the Crossref API instead — title, venue, author order and `pp. 1-7` all match the citation. |
| **V9** | Toggle flips theme, writes `localStorage`, survives reload, and carries across to `/ko/`. `aria-pressed` and `aria-label` stay in sync, and the label localizes (`라이트 모드로 전환`). `data-theme` is set at parse time, so no flash. |
| **V10** | W3C Nu validator: **0 errors, 0 warnings** on both pages. |
| **images** | 0 broken images across 7 render passes; both featured figures load at their true natural size. |

Two things the verification caught that review would not have:

1. **An invalid favicon.** The original inline `data:image/svg+xml,<svg …>` URI contained raw `<` and `>`, which are illegal unescaped in a URL. It was the only HTML error in either file. Replaced with a real `favicon.svg`.
2. **Korean headings inheriting body leading.** `:lang(ko)` is a pseudo-class with specificity (0,1,0), so it outranked the bare `h1, h2, h3, h4` selector and gave Korean headings the 1.8 body line-height instead of 1.2. Visible as an oversized gap between the two lines of 안녕하세요, / 윤지영입니다. Fixed with an explicit `h1:lang(ko)` rule; the uppercase tracking on section titles was also dialled back for Hangul at the same time.

One false alarm worth recording, so it is not re-investigated later: screenshots taken with Chrome's `--window-size` flag appear to show text clipped at 375 px. They do not. `--window-size` does not set the layout viewport the way `Emulation.setDeviceMetricsOverride` does, so the page lays out wider and the capture crops it. Measured through proper device emulation, `scrollWidth` is exactly 375. Similarly, `loading="lazy"` images render blank under `captureBeyondViewport` until something scrolls; they are not broken.

---

## 8. Appendix — verbatim source content

The authoritative text, as extracted from Notion. The build copies from here; V4 diffs against it. Preserved exactly, including the source's own typos (`Unversity`, `KIm`, `Expriment`) — **these are corrected in the built site**, and each correction is listed in §8.3.

### 8.1 English

**About**

> Hi, my name is Jiyoung Yun.
>
> After receiving my Bachelor of Fine Arts from Sungkyunkwan University and a Master's degree from KAIST, I am currently working as a user researcher at [KRAFTON](krafton.com).
>
> I conduct user research for games currently under development at studios within KRAFTON which are located across the world including United States, Sweden, Spain, and South Korea. I am also responsible for developing research methodologies for game user research, spanning both qualitative and quantitative approaches using eye tracking and behavioral data.
>
> Recently, I have become interested in improving AI assistance through gaze, task context, and user feedback. In particular, I aim to investigate whether such assistance can support comprehension and reduce interaction effort while preserving users' sense of control.

**Education & Work**

| | |
|---|---|
| 2024 - present | User Researcher, KRAFTON<br>Responsible for user research and developing methodologies |
| 2024 - 2024 | UX Researcher, NC SOFT<br>Responsible for conducting UX analysis for game products |
| 2021 - 2024 | Master of Science in Cultural Technology, KAIST<br>Thesis: Relationship between trustworthy museum instagram posts cues and museum brand attitudes: a focus on users in their 20s<br>IBD lab, supervised by Professor Jihyeon Lee |
| 2020 - 2021 | Research Internship, Sungkyunkwan Unversity<br>HAI lab, supervised by Professor Hayeon Song |
| 2015 - 2021 | Bachelor of Fine Arts (B.F.A.) & Media Arts (Double Major), Sungkyunkwan University |
| 2016 - 2016 | Curatorial Internship, uJung Art Center |

**Publication**

| | |
|---|---|
| 2022. 04<br>2nd author | Lee, S., Yun, J., Lee, S., Song, Y., & Song, H. (2022, April). Will AI image synthesis technology help constructivist education at the online art museum?. In CHI conference on human factors in computing systems extended abstracts (pp. 1-7). |
| 2022. 10<br>co-1st author | Lee, S. U., Yun, J., Kim, D., Kim, D., Oh, S. Y., & Yoon, S. H. (2022, October). Cards: Comprehensive ar docent system. In 2022 IEEE International Symposium on Mixed and Augmented Reality Adjunct (ISMAR-Adjunct) (pp. 739-743). IEEE. |
| 2022. 10<br>co-1st author | KIm, B. W., Park, J., & Yun, J. (2023). Metaverse communication channel to Enhance Comradery of Telecommuter. In 2023 Proceedings of HCI KOREA (pp. 1115-1120). |
| 2023. 06<br>5th author | Pyo, H., Lee, G., Kim, G., Lee, J., Yun, J., & Lee., J. (2023). Dynamic Community Detection based on Temporal Behavior Data in Virtual Conferences: Emergence and Growth of Social Communities in Conference. In KCC 2023 (pp. 1413 - 1415). Korean Institute of Information Science and Engineers. |
| 2023. 09<br>1st author | Yun, J. Y., & Lee, J. H. (2023). Analysis of Museum Social Media Posts for Effective Social Media Management. In Cultural Space on Metaverse (pp. 175-191). Singapore: Springer Nature Singapore. |
| 2023. 09<br>3rd author | Lee, G. B., Chang, M., Yun, J. Y., & Lee, J. H. (2023). Spatial Behavior Data in Virtual Conference: Proximity and Network Analysis. In Cultural Space on Metaverse (pp. 133-145). Singapore: Springer Nature Singapore. |

**Teaching Experience** — 2023, Spring — Teaching Assistant, Creative Expriment Practice, KAIST

**Contact** — Email : clatya96@gmail.com  *(link in source points to `clatya96@krafton.com`)*

**Featured**

1. *CARDS: Comprehensive AR Docent System* — Lee, S. U., Yun, J., Kim, D., Kim, D., Oh, S. Y., & Yoon, S. H. 2022 IEEE International Symposium on Mixed and Augmented Reality Adjunct (ISMAR-Adjunct) — 🔗 <https://ieeexplore.ieee.org/abstract/document/9974452>
2. *Will AI Image Synthesis Technology Help Constructivist Education at The Online Art Museum?* — Lee, S., Yun, J., Lee, S., Song, Y., & Song, H. CHI conference on human factors in computing systems extended abstracts — 🔗 <https://dl.acm.org/doi/10.1145/3491101.3519788>

### 8.2 Korean

**About**

> 안녕하세요, 윤지영입니다.
>
> 성균관대학교에서 미술학 및 영상학 학사과정을 마치고, 카이스트 문화기술대학원에서 공학 석사과정을 마쳤습니다. 현재는 [크래프톤](http://krafton.com)에서 유저 리서처로 근무하고 있습니다.
>
> 크래프톤 산하의 스튜디오는 스웨덴, 스페인, 한국 등 세계 각지에 흩어져 있습니다. 저는 해당 스튜디오에서 개발하는 게임의 사용자 조사를 담당하고 있으며, 게임 사용성 조사에 알맞는 정성적, 정량적 연구 방법론을 개발하고 있습니다. 개발한 연구 방법론 일부는 시선 데이터를 활용합니다.
>
> 최근에는 시선, 과제 맥락, 사용자 피드백을 활용한 AI 개선에 관심이 있습니다. 특히 이러한 지원이 사용자의 통제감을 유지하면서 이해를 돕고 상호작용에 필요한 노력을 줄일 수 있는지에 조사하고자 합니다.

**Education & Work**

| | |
|---|---|
| 2024 - 현재 | User Researcher, KRAFTON<br>게임 유저 리서치 및 리서치 방법론 개발 |
| 2024 - 2024 | UX Researcher, NC SOFT<br>게임 UX/UI 분석 |
| 2021 - 2024 | 문화기술대학원 (Master of Science), 한국과학기술원 (KAIST)<br>졸업 논문: Relationship between trustworthy museum instagram posts cues and museum brand attitudes: a focus on users in their 20s<br>IBD lab, 지도교수: 이지현 |
| 2020 - 2021 | Research Internship, Sungkyunkwan Unversity<br>HAI lab, 지도교수: 송하연 |
| 2015 - 2021 | 미술학과 (Bachelor of Fine Arts) & 영상학과 (Media Arts) (복수전공), 성균관대학교 |
| 2016 - 2016 | 큐레이팅 인턴십, uJung Art Center |

**Publication** — same six entries with Korean authorship labels (2저자 / 공동 1저자 / 공동 1저자 / 5저자 / 1저자 / 3저자). Two entries differ from the English page:

- HCI KOREA 2023 → KIm, B. W., Park, J., & Yun, J. (2023). **원격근무 환경에서 직원 간 유대관계 증진을 위한 메타버스 소통 창구.** In 2023 Proceedings of HCI KOREA (pp. 1115-1120).
- KCC 2023 → Pyo, H., Lee, G., Kim, G., Lee, J., Yun, J., & Lee., J. (2023). **가상 컨퍼런스 속 시계열 행동데이터 기반의 동적 커뮤니티 검출.** In KCC 2023 (pp. 1413 - 1415). Korean Institute of Information Science and Engineers.

**Teaching Experience** — 2023, Spring — Teaching Assistant, 창의적 실험 실습, KAIST

**Contact** — Email : clatya96@krafton.com → **becomes `clatya96@gmail.com`** on the new site, per the decision in `PROJECT_PLAN.md` §3.

**Featured** — section heading "Featured Publications"; same two cards as English.

### 8.3 Corrections applied to the source content

Content is otherwise carried over verbatim. These are the only changes, all of them fixes to defects in the Notion original:

| | Source | Built site | Why |
|---|---|---|---|
| 1 | `krafton.com` (no scheme) | `https://krafton.com` | The source link is relative and therefore broken. |
| 2 | Email text `@gmail.com`, link `@krafton.com` | both `clatya96@gmail.com` | The source text and link disagree; owner chose Gmail. |
| 3 | `Sungkyunkwan Unversity` | `Sungkyunkwan University` | Typo. |
| 4 | `Creative Expriment Practice` | `Creative Experiment Practice` | Typo. |
| 5 | `KIm, B. W.` | `Kim, B. W.` | Typo in a published author's name. |
| 6 | `Lee., J.` | `Lee, J.` | Stray period. |
| 7 | `NC SOFT` | `NCSOFT` | Company's own styling. |
| 8 | `Cards: Comprehensive ar docent system` | `CARDS: Comprehensive AR Docent System` | Matches the published title and the site's own Featured section, which already uses the correct form. |
| 9 | `museum instagram posts cues` | `museum Instagram post cues` | Proper noun + grammar, in a thesis title shown to reviewers. |

Items 3–9 are judgement calls on a document that academic and hiring readers will scrutinise. Say the word and any of them can be reverted to the Notion wording.

---

## 9. Build order

1. Resize and re-encode the three images; re-verify magic bytes. *(§3.3)*
2. `css/style.css` — tokens, normalize, layout, components, theme, motion, print.
3. `index.html` — English, with the full head block.
4. `ko/index.html` — Korean, mirroring the structure.
5. `js/main.js` — theme toggle, scroll-spy.
6. `.nojekyll`, `.gitignore`, `README.md`.
7. Verification V1–V10; fix and re-run until clean.
8. `git init`, commit, add remote. **No push.**
9. Report: what was verified and how, plus the four manual deploy steps.

CSS comes before the HTML so that class names are settled once and both pages are written against a finished vocabulary, rather than the markup and styles being reconciled afterwards.
