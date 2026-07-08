# NeoFreeBird — working notes

Fork of the **NeoFreeBird** tweak that hooks the native Twitter/X **iOS app**
(`com.atebits.Tweetie2`) via Theos/Logos (`Tweak.x`, `BHTManager.m`,
`ModernSettingsViewController.m`). Not a browser extension; not compiled with
Xcode. Built with `build.sh` (upstream) or `build-classic.sh` (branded).

## Repo relationships
- `origin` = `theacrat/NeoFreeBird` (upstream tweak source). `master` tracks it.
- `fork`   = `gingerbeardman/NeoFreeBird` (Matt's fork; push here).
- Matt's feature work is merged upstream via PRs, so the fork mostly **tracks the
  parent** — sync with a fast-forward of `master`, don't carry long-lived patches.
- Upstream version tags lag `master` by a release (e.g. `master` = 5.3.0 while the
  latest tag is v5.2.9). Pin to a tag only when explicitly asked.

## Branding — READ THIS BEFORE BRANDING ANYTHING
There are **two** branding systems in the tree; they are not equivalent.

- ✅ **`classic-branding/`** (git submodule → `gingerbeardman/twitter-classic-branding`)
  is the **canonical, full** classic-Twitter brander: bird **feed logo**
  (`VectorImages/main/twitter.svg`), **feather compose** (`compose.svg` +
  `composer_fab_icon_option=""`), bird **launch `xLogo`**, bird **app icons**,
  English **wording** rebrand, tweak inject, "Twitter" name. Version-adaptive.
  Ships no artwork — `fetch-sources.sh` pulls it from `NeoFreeBird/app` at runtime;
  `sources/home-icon.png` is preserved locally (regenerated from the bird SVG if absent).
- ⚠️ **`branding/`** (upstream, tracked; `build.sh` sources `ipa-branding.sh`) is a
  **light** path: app icons + display name **only**. `build.sh --twitter-branding
  --image-pack` leaves the **feed logo X**, **compose "+"**, and **launch screen
  blank**. Do NOT use it for real branding.

## Build a branded IPA (the normal deliverable)
```bash
./build-classic.sh [decrypted-twitter.ipa]   # no arg = newest packages/*_und3fined.ipa
# -> packages/NeoFreeBird-Twitter-<nfb>_<xver>-classic.ipa
```
This builds the tweak dylibs if missing, runs `classic-branding/rebrand.sh`, then
injects the Safari extension in a second cyan pass. Prereqs: Theos (`$THEOS`),
`cyan` (pyzule-rw, with pillow), Xcode (`actool`/`assetutil`/`clang`),
`rsvg-convert`, `imagemagick`.

## Open in Twitter Safari extension
Prebuilt `assets/OpenTwitterSafariExtension.appex` (vendored from `NeoFreeBird/app`).
cyan drops any `.appex` into the app's `PlugIns/`. `build.sh` injects it for
`--sideloaded`/`--trollstore`; `build-classic.sh` adds it via a second pass
(the submodule's `rebrand.sh` has no Safari step). Redirects x.com/twitter.com
links opened in Safari to the `twitter://` scheme.

## Gotchas
- **IPA filenames lie.** `und3fined` names files by the App Store version, which
  can be a patch behind the bundle — `..._12.6_...ipa` is really **12.6.1**
  (`CFBundleShortVersionString`). Trust the plist; name outputs from it.
- **cyan overwrite prompt** EOFs in non-interactive runs — always pass `--overwrite`.
- Input IPAs live in gitignored `packages/`; so do Matt's bird masters
  (`packages/new-bird-assets/`). These are not committed.

## Commits
Author as **Matt Sephton**; **no** Claude/Co-Authored-By/Generated-with footers.
