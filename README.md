# Jiyoung Yun — Portfolio

Personal portfolio site for Jiyoung Yun (윤지영), user researcher at KRAFTON.

**Live:** <https://clatya96.github.io/> · **Korean:** <https://clatya96.github.io/ko/>

Plain HTML, CSS and JavaScript. No build step, no dependencies, no package manager — the files in this repository are exactly what the browser receives.

---

## Quick start

```bash
cd C:\Users\clatya96\Projects\Github_website
python -m http.server 8000
```

Then open <http://localhost:8000/>.

> **Use the server, not the file.** Double-clicking `index.html` opens it over `file://`, where the `/ko/` link and some relative paths behave differently. Always preview through `http.server`.

---

## Deploying for the first time

The repository is already committed locally with a remote configured. Three steps remain:

**1. Create the GitHub repository**

Go to <https://github.com/new> and create a repository named **exactly**:

```
clatya96.github.io
```

- Visibility: **Public** (required for free GitHub Pages)
- Do **not** add a README, `.gitignore`, or license — they would conflict with the existing commit

> The name must match the username exactly. If it is named anything else, Pages serves the site from a `/subpath` instead of the root, and every link breaks. This is the single most common mistake with GitHub Pages.

**2. Push**

```bash
git push -u origin main
```

**3. Enable Pages**

In the repository: **Settings → Pages → Build and deployment**

- Source: **Deploy from a branch**
- Branch: **`main`**, folder: **`/ (root)`**
- Save

Wait about a minute, then open <https://clatya96.github.io/>.

After this, every `git push` redeploys automatically:

```bash
git add -A
git commit -m "Update publications"
git push
```

### If the site 404s

Almost always one of two things: the repository is not named exactly `clatya96.github.io`, or the branch/folder in step 3 is not `main` / `/ (root)`. Check those before anything else.

---

## Editing the content

| To change | Edit | Section |
|---|---|---|
| Bio paragraphs | `index.html` **and** `ko/index.html` | `#about` |
| Job or degree | `index.html` **and** `ko/index.html` | `#education` |
| Publication | `index.html` **and** `ko/index.html` | `#publications` |
| Featured cards | `index.html` **and** `ko/index.html` | `#featured` |
| Teaching | `index.html` **and** `ko/index.html` | `#teaching` |
| Email | `index.html` **and** `ko/index.html` | `#contact` |
| Colours, fonts, spacing | `css/style.css` | tokens at the top (`:root`) |
| Theme toggle, scroll-spy | `js/main.js` | — |

> ### Content edits must be made twice
>
> English lives in `index.html`, Korean in `ko/index.html`, and each is a standalone document. Changing your bio in one file does **not** change the other.
>
> This is deliberate: it keeps both languages in the HTML source, so search engines, Google Scholar, and link previews can read them, and both pages work without JavaScript. The cost is double editing. The two files use identical structure and class names, so `diff` shows only the text that differs.

### Adding a publication

Copy an existing `<li class="pub">` block in the `#publications` list and edit it. Keep the structure:

```html
<li class="pub">
  <p class="pub__meta">
    <time class="pub__date" datetime="2024-05">2024. 05</time>
    <span class="pub__role">1st author</span>
  </p>
  <p class="pub__cite">
    <strong>Yun, J. Y.</strong>, &amp; Someone, A. (2024).
    <cite>Title of the paper.</cite> In
    <span class="pub__venue">Venue Name</span> (pp. 1&ndash;10).
    <a class="pub__link" href="https://doi.org/...">DOI &#8599;</a>
  </p>
</li>
```

- `<strong>` wraps your own name so your author position is scannable
- `datetime` on `<time>` is machine-readable (`YYYY-MM`); the visible text can be formatted however you like
- Drop the `<a class="pub__link">` entirely if there is no public link — do not link to a paywall landing page that does not resolve
- On the Korean page, use `공동 1저자` / `2저자` / `3저자` style labels and add `lang="en"` to `.pub__cite` if the citation is in English

### Replacing the CV

Overwrite `assets/CV_JiyoungYun.pdf`, keeping the filename, then commit. No HTML edit needed.

If the file size changes noticeably, update the `PDF, 104 KB` hint in the `#contact` section of both pages.

### Changing colours

Every colour is a custom property at the top of `css/style.css`. Light theme in `:root`, dark theme in **two** places — the `@media (prefers-color-scheme: dark)` block and the `:root[data-theme="dark"]` block. Both need the same values; the first follows the OS setting, the second is the manual toggle.

---

## Structure

```
.
├── index.html            English page
├── ko/index.html         Korean page
├── css/style.css         single stylesheet (tokens → layout → components → media)
├── js/main.js            theme toggle + scroll-spy, ~115 lines, no dependencies
├── assets/
│   ├── profile.jpg
│   ├── featured-cards.jpg
│   ├── featured-chi.jpg
│   └── CV_JiyoungYun.pdf
├── .nojekyll             tells GitHub Pages to serve files as-is
├── PROJECT_PLAN.md       what was built and why
└── DEVELOPMENT.md        how it was built, with the verbatim source content
```

### Why `.nojekyll`

GitHub Pages runs every site through Jekyll by default, which ignores files starting with `_` and tries to interpret `{{ }}` and `{% %}` in HTML as template syntax. The empty `.nojekyll` file disables that. Do not delete it.

---

## Adding a custom domain

1. Create a file named `CNAME` at the repository root containing only the bare domain:
   ```
   jiyoungyun.com
   ```
2. At your DNS provider, add a `CNAME` record pointing `www` at `clatya96.github.io`. For the apex domain, add `A` records pointing at GitHub's four Pages IPs (listed in [GitHub's docs](https://docs.github.com/pages/configuring-a-custom-domain-for-your-github-pages-site)).
3. In **Settings → Pages**, enter the domain and tick **Enforce HTTPS** once the certificate is issued (can take up to 24 hours).
4. Update the absolute URLs in the `<head>` of both HTML files — `canonical`, the three `hreflang` links, `og:url`, and `og:image`.

Step 4 is easy to forget, and skipping it leaves search engines pointing at the old `github.io` address.

---

## Source

The content was migrated from a [Notion page](https://salty-morning-69c.notion.site/Jiyoung-Yun-379c9a728c5c80dd8ed8c449607e94e6). `DEVELOPMENT.md` §8 holds the verbatim original text and lists the nine corrections applied during migration (a broken link, an email mismatch, and seven typos). The site has no runtime dependency on Notion.
