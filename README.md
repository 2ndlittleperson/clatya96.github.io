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

## 다른 PC에서 배포하기

이 폴더는 아직 GitHub에 push되지 않았기 때문에, 다른 PC에서 `git clone`으로 받을 수 없습니다. 폴더를 **커밋 기록(`.git`)까지 포함해서** 직접 옮긴 뒤, 그 PC에서 push합니다.

### 1. 코드 옮기기 (원래 PC에서)

둘 중 하나를 고릅니다.

**방법 A — 폴더 통째로 복사 (가장 간단)**

폴더 전체를 USB, 클라우드 드라이브, zip 등으로 옮깁니다.

> **숨김 폴더 `.git`이 반드시 같이 가야 합니다.** 탐색기에서 숨김 항목이 안 보이는 상태로 복사하거나, `.git`을 빼고 압축하면 커밋 기록과 원격 설정이 사라집니다. zip으로 묶을 때는 폴더 자체를 우클릭해서 압축하세요(폴더 안의 파일만 선택해서 압축하면 `.git`이 빠질 수 있음).

**방법 B — git bundle (파일 하나로 옮기기)**

```bash
cd C:\Users\clatya96\Projects\GIthub_website
git bundle create portfolio.bundle --all
```

bundle에는 **커밋된 내용만** 들어갑니다. 만들기 전에 `git status`로 커밋 안 된 변경이 없는지 확인하세요.

생성된 `portfolio.bundle` 파일 하나만 옮기면 됩니다. 새 PC에서:

```bash
git clone portfolio.bundle GIthub_website
cd GIthub_website
git remote set-url origin https://github.com/<GitHub아이디>/<GitHub아이디>.github.io.git
```

(bundle에서 clone하면 `origin`이 bundle 파일을 가리키므로 마지막 줄로 GitHub 주소로 바꿔줘야 합니다.)

### 2. 새 PC 준비

1. **Git 설치** — <https://git-scm.com/download/win>. Git for Windows에는 Git Credential Manager가 포함되어 있어서, 처음 push할 때 브라우저 창이 떠서 GitHub 로그인만 하면 됩니다. 토큰을 따로 만들 필요는 없습니다.
2. **커밋 작성자 설정** (그 PC에서 처음 Git을 쓰는 경우)
   ```bash
   git config --global user.name "Jiyoung Yun"
   git config --global user.email "clatya96@gmail.com"
   ```
3. **(선택) Python** — 로컬 미리보기(`python -m http.server`)에만 필요합니다. 배포 자체에는 필요 없습니다.

### 3. 옮겨온 상태 확인

```bash
cd <옮긴 폴더 경로>
git status          # "nothing to commit, working tree clean" 이어야 함
git log --oneline   # 기존 커밋들이 보여야 함
git remote -v       # origin 이 GitHub 저장소 주소인지 확인
```

`git status`가 `not a git repository`라고 나오면 `.git` 폴더가 빠진 것입니다. 원래 PC에서 다시 옮기세요.

### 4. GitHub 아이디 확인 — 중요

저장소 이름은 **`<GitHub아이디>.github.io`** 여야 하고, 코드 안의 주소는 현재 `clatya96` 기준으로 되어 있습니다. <https://github.com/clatya96> 이 본인 계정이 아니라면(2026-10-27 기준 404), 실제 아이디로 아래를 모두 바꿔야 합니다.

- 원격 주소
  ```bash
  git remote set-url origin https://github.com/<GitHub아이디>/<GitHub아이디>.github.io.git
  ```
- `index.html`과 `ko/index.html`의 `<head>`에 있는 `https://clatya96.github.io` — `canonical`, `hreflang` 3개, `og:url`, `og:image`, JSON-LD의 `"url"`, `"image"` (파일당 8곳)
- 이 README 상단의 **Live** 링크

바꾼 뒤 커밋합니다.

```bash
git add -A
git commit -m "Use correct GitHub username in URLs"
```

### 5. 배포

위의 [Deploying for the first time](#deploying-for-the-first-time) 1~3단계를 그대로 따릅니다.

1. <https://github.com/new> 에서 `<GitHub아이디>.github.io` 이름으로 **Public** 저장소 생성 (README, `.gitignore`, license 추가 **안 함**)
2. `git push -u origin main` — 브라우저 로그인 창이 뜨면 GitHub 계정으로 로그인
3. 저장소 **Settings → Pages** → Source: **Deploy from a branch** → `main` / `/ (root)` → Save

1분쯤 뒤 `https://<GitHub아이디>.github.io/` 에서 확인합니다.

### 이후에는

한 번 push한 뒤로는 어느 PC에서든 그냥 clone해서 작업하면 됩니다.

```bash
git clone https://github.com/<GitHub아이디>/<GitHub아이디>.github.io.git
```

여러 PC를 오가며 수정할 때는 작업 시작 전에 `git pull`, 끝나면 `git push`를 습관으로 하세요. 한쪽에서 pull 없이 수정하면 push할 때 충돌이 납니다.

> 이 문서의 `C:\Users\clatya96\Projects\...` 경로는 원래 PC 기준입니다. 새 PC에서는 폴더를 옮긴 실제 경로로 바꿔 읽으세요.

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
