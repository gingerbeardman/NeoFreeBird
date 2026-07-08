#!/usr/bin/env bash
#
# build-classic.sh — ONE command to produce a classic-Twitter-branded NeoFreeBird
# IPA with the "Open in Twitter" Safari extension, from a decrypted Twitter/X IPA.
#
# Usage:
#   ./build-classic.sh [decrypted-twitter.ipa]
#   (no arg = newest packages/com.atebits.Tweetie2_*_und3fined.ipa)
#
# It:
#   1. builds the tweak dylibs (make SIDELOADED=1) if they're missing
#   2. runs classic-branding/rebrand.sh  — the CANONICAL full brander:
#        bird feed logo, feather compose (+ composer_fab_icon_option), bird launch
#        xLogo, bird app icons, English wording rebrand, tweak inject, "Twitter" name
#   3. injects assets/OpenTwitterSafariExtension.appex via a second cyan pass
#   4. names the output from the ACTUAL bundle version, not the (often wrong) filename
#
# NOTE: do NOT use `build.sh --twitter-branding --image-pack` for real branding —
# that upstream path only swaps app icons + the display name. It leaves the feed
# logo as X, the compose button as "+", and the launch screen blank.
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
REPO="$PWD"
say(){ printf "\033[1;36m==>\033[0m %s\n" "$*"; }
die(){ printf "Error: %s\n" "$*" >&2; exit 1; }

command -v cyan >/dev/null || die "cyan not found (pip/pipx install pyzule-rw, with pillow)"

IPA_IN="${1:-$(ls -t packages/com.atebits.Tweetie2_*_und3fined.ipa 2>/dev/null | head -1)}"
[ -n "$IPA_IN" ] && [ -f "$IPA_IN" ] || die "no input IPA (pass one, or drop a decrypted IPA in packages/)"

# 1) tweak dylibs
export TWEAK_DYLIBS="$REPO/.theos/obj/debug"
export TWEAK_BUNDLE="$REPO/layout/Library/Application Support/BHT/BHTwitter.bundle"
if [ ! -f "$TWEAK_DYLIBS/BHTwitter.dylib" ]; then
  say "building tweak (make SIDELOADED=1)"
  : "${THEOS:=$HOME/theos}"; export THEOS
  [ -d "$THEOS" ] || die "Theos not found at \$THEOS ($THEOS)"
  make SIDELOADED=1
fi

# 1b) branding submodule
[ -f classic-branding/rebrand.sh ] || { say "init classic-branding submodule"; git submodule update --init classic-branding; }

# 2) name from the ACTUAL bundle version (und3fined filenames are often off by a patch)
tmp="$(mktemp)"; unzip -p "$IPA_IN" 'Payload/*.app/Info.plist' > "$tmp" 2>/dev/null || true
XVER="$(plutil -extract CFBundleShortVersionString raw "$tmp" 2>/dev/null || echo unknown)"; rm -f "$tmp"
NFB="$(awk '/^Version:/{print $2}' control)"
BRANDED="packages/.branded-nosafari.tmp.ipa"
FINAL="packages/NeoFreeBird-Twitter-${NFB}_${XVER}-classic"   # cyan appends .ipa

# 3) full classic branding + tweak
say "branding $(basename "$IPA_IN")  ->  Twitter $XVER, NeoFreeBird $NFB"
bash classic-branding/rebrand.sh "$IPA_IN" "$BRANDED"

# 4) Open in Twitter Safari extension (second cyan pass; --overwrite avoids the
#    interactive prompt that EOFs in non-interactive runs)
say "injecting Open in Twitter Safari extension"
cyan -i "$BRANDED" -o "$FINAL" --ignore-encrypted --overwrite -f assets/OpenTwitterSafariExtension.appex
rm -f "$BRANDED"

say "done -> ${FINAL}.ipa"
ls -lh "${FINAL}.ipa" | awk '{print "    size:",$5}'
