# fluffychat.ir

A resilience-focused Persian mirror of the [FluffyChat](https://fluffychat.im) landing page, forked from [krille-chan/fluffychat-website](https://github.com/krille-chan/fluffychat-website).

Deployed in Iran so that Iranian users can discover and access FluffyChat even when international internet connectivity is severed. The companion app instance at `app.fluffychat.ir` runs the official FluffyChat web app on the same infrastructure.

## Why this exists

Iran's government routinely imposes full internet blackouts to suppress protests and control information flow. The [2026 Internet blackout](https://en.wikipedia.org/wiki/2026_Internet_blackout_in_Iran), beginning January 8, cut the country to as low as 1% of normal connectivity for weeks, costing the economy $35.7 million per day and leaving tens of millions without access to communication tools.

During these shutdowns, websites hosted outside Iran become completely unreachable, and people are forced to rely on state-owned messaging platforms that are controlled by the Islamic Republic and have no regard for user privacy. This has pushed more Iranians to seek out decentralized, self-hosted alternatives. [Matrix](https://matrix.org) in particular is gaining traction in Iran as people learn that no single government can shut it down or read their messages.

This project exists to make that discovery easier for non-technical users. A Persian-language landing page hosted inside Iran means someone can learn what Matrix is, understand the FluffyChat client, and start using it -- all without needing a VPN or any access to the international internet. By hosting both the landing page and a FluffyChat app instance on Iranian servers, this project ensures that users inside Iran can still find and use a Matrix client when they need it most.

## What changed from the original

### Stripped i18n and simplified to Persian-only
- Removed the multi-language pagination system (11 languages, `i18n.js` loader, per-language JSON files, locale-detection redirects).
- Created a flat `src/_data/site.json` with all UI strings in Persian, referenced directly as `site.key` in templates.
- Removed all pages except the landing page: FAQ, Changelog, Impressum, Privacy, and Terms of Service are no longer hosted locally. The footer links to these pages on the official site instead.
- Simplified `eleventy.config.js` by removing the unused `t` translation filter.
- The landing page is served directly from `/` instead of `/{lang}/`.

### Language, direction, and typography
- All UI text translated to Persian.
- HTML `lang` set to `fa`, `dir` set to `rtl`.
- Fixed a duplicate `<html>` tag bug in the original `layout.njk`.
- Replaced Zen Kurenaido (which was referenced but never loaded) with self-hosted [Vazirmatn](https://github.com/rastikerdar/vazirmatn) variable-weight woff2 as the primary font. Zen Kurenaido is self-hosted as a secondary font for Latin characters.
- Fonts are self-hosted in `src/assets/fonts/` rather than loaded from Google CDN, because Google services are unreachable during blackouts.
- All physical directional Tailwind classes (`pr-`, `mr-`, `space-x-`) replaced with direction-agnostic equivalents (`gap-*`) for proper RTL rendering.

### Navigation
- Simplified to: Home (internal), FAQ (external to official site), Blog (external to Ko-Fi), Ko-Fi donate button, and Mastodon link.
- Removed Changelog link from nav.

### Footer
- Legal page links (Impressum, Privacy, Terms) now point to the official site externally.
- Removed the language picker.
- Added a line crediting this as an unofficial Persian clone with a link to this repository and the upstream repository.

### Direct download system
- Added a "دانلود مستقیم" (Direct Download) button on the landing page linking to `/download/`.
- Created `src/download.njk`: a download page listing all release assets (APK, Linux x64, Linux ARM64, Web) with filenames and file sizes.
- Created `scripts/update-apk.sh`: a bash script that queries the GitHub Releases API for [krille-chan/fluffychat](https://github.com/krille-chan/fluffychat/releases), downloads all release assets (excluding source archives) to `src/assets/downloads/`, and generates `src/_data/downloads.json` with metadata for the template.
- The download files are gitignored; the script is run on the server before rebuilding.

### Links
- The "Open in browser" badge now points to `app.fluffychat.ir` instead of `fluffychat.im/web`.
- External links (GitHub, Matrix, Ko-Fi, Mastodon, etc.) left unchanged.

### Meta and SEO
- Page title set to Persian ("فلافی‌چت").
- Meta description, Open Graph tags, and keywords updated for Persian and `fa_IR` locale.
- Open Graph URL set to `https://fluffychat.ir`.

### Build and deployment
- Removed `prepare.sh` (fetched changelog/privacy from upstream, no longer needed).
- GitHub Actions workflow simplified: removed `prepare.sh` step.
- Site is deployed to a VPS in Iran rather than GitHub Pages.

## Files

| File | What changed |
|---|---|
| `src/_includes/layout.njk` | Fixed HTML structure, `lang="fa" dir="rtl"`, Vazirmatn font stack, Persian meta/OG tags, simplified nav, footer rewrite with external legal links and clone credit |
| `src/index.njk` | Removed i18n pagination, serves from `/`, `site.X` references, RTL-safe Tailwind classes, direct download button |
| `src/styles.css` | `@font-face` for Vazirmatn and Zen Kurenaido, removed `.markdown` styles (no article pages), download button color override |
| `src/download.njk` | New page listing all release assets with version, filename, and file size |
| `src/_data/site.json` | All Persian UI strings (tagline, 9 features, nav labels, footer labels) |
| `src/_data/downloads.json` | Generated by `scripts/update-apk.sh`, contains release metadata |
| `scripts/update-apk.sh` | Fetches latest release assets from GitHub API |
| `eleventy.config.js` | Removed `t` filter |
| `src/assets/fonts/` | Self-hosted Vazirmatn Variable (woff2) and Zen Kurenaido Regular (woff2) |

**Deleted:** `src/_data/i18n.js`, `src/_data/i18n/*.json`, `src/forward.njk`, `src/forward_faq.njk`, `src/faq.njk`, `src/impressum.njk`, `src/changelog.md`, `src/privacy.md`, `src/tos.md`, `src/_includes/article.njk`, `src/_data/contact.json`, `prepare.sh`

## Build

```sh
npm install
npx tailwindcss -i ./src/styles.css -o ./src/assets/tailwind.css --minify
npx @11ty/eleventy
```

Output is in `./public/`.

### Update downloads

```sh
./scripts/update-apk.sh
```

### Run locally

```sh
npx @11ty/eleventy --serve
```

## Deployment

Static files served by nginx. See the [original repository](https://github.com/krille-chan/fluffychat-website) for upstream changes.

### Analytics

Basic visit metrics are publicly available at `/metrics`. They are generated from nginx access logs by [GoAccess](https://goaccess.io/) and refreshed every five minutes via cron. No JavaScript tracking, no cookies, no external services.

**Setup:**

1. Install GoAccess:
   ```
   apt install goaccess
   ```

2. Add a cron job (`crontab -e`):
   ```
   */5 * * * * goaccess /var/log/nginx/access.log -o /var/www/fluffychat.ir/metrics/index.html --log-format=COMBINED
   ```
   Adjust the log and output paths to match your server layout.

3. Add an nginx location block inside the `fluffychat.ir` server config:
   ```nginx
   location /metrics {
       alias /var/www/fluffychat.ir/metrics;
       index index.html;
   }
   ```

4. Reload nginx:
   ```
   systemctl reload nginx
   ```

The metrics page is intentionally public — there is no sensitive data in it, and transparency about traffic is consistent with the project's open-source ethos.

## Credits

- Original project by [Krille Fear (krille-chan)](https://github.com/krille-chan) - [krille-chan/fluffychat-website](https://github.com/krille-chan/fluffychat-website)
- Persian version by [Pourya Erfanzadeh](https://github.com/erfnzdeh)
- Font: [Vazirmatn](https://github.com/rastikerdar/vazirmatn) by Saber Rastikerdar (OFL-1.1)
