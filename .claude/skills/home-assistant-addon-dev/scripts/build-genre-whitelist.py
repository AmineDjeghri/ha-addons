"""Build the beets genre-whitelist supplement (genres-extra.txt).

Merged at addon startup with beets' bundled genres.txt (see home-assistant-addon-dev
skill, references/beets-genre-whitelist.md). Re-run whenever:
- the Spotify/EveryNoise catalog changes, or
- the user's library gains new raw last.fm tags worth admitting.

Usage:
    python3 build-genre-whitelist.py [-t TAGS_FILE] [-o OUTPUT]

  TAGS_FILE : file with the library's unique raw last.fm tags, one per line,
              lowercase (extract via docker exec + awk, see the reference doc).
              Optional — without it, only Spotify + regional tiers are built.
  OUTPUT    : default genres-extra.txt in the current directory.

Sources fetched live: beets genres.txt (raw.githubusercontent) and the
Spotify/EveryNoise gist (a MARKDOWN list "1. Name" — NOT JSON).
"""

import argparse
import re
import urllib.request

BEETS_URL = "https://raw.githubusercontent.com/beetbox/beets/master/beetsplug/lastgenre/genres.txt"
SPOTIFY_URL = "https://gist.githubusercontent.com/andytlr/4104c667a62d8145aa3a/raw"

# Non-genres that slip into Spotify's catalog; keep this list small.
JUNK_BLACKLIST = {
    "comic",
    "commons",
    "corrosion",
    "drama",
    "fake",
    "guidance",
    "laboratorio",
    "motivation",
    "ninja",
    "reading",
    "sleep",
    "tribute",
    "wrestling",
    "workout",
    "hoerspiel",
    "hollywood",
    "idol",
    "poetry",
    "oratory",
    "praise",
    "relaxative",
    "remix",
    "scratch",
    "sega",
    "shanty",
    "talent show",
}

# Regional descriptors meaningful for a French/Arabic/European library.
REGIONAL = [
    "north african",
    "maghreb",
    "maghrebi",
    "maghreb pop",
    "moroccan pop",
    "algerian pop",
    "arabic music",
    "arabica",
    "chaabi",
    "african pop",
    "afropop",
    "amapiano",
    "dembow",
    "french rap",
    "french rnb",
    "pop latino",
    "spanish rap",
    "trap latino",
]

# Real genres this library actually used that beets+Spotify both miss.
LIBRARY_DERIVED = [
    "adult contemporary",
    "alt-pop",
    "alternative rnb",
    "ambient pop",
    "arena rock",
    "art pop",
    "atmospheric drum and bass",
    "balada",
    "baltimore club",
    "bedroom pop",
    "big room house",
    "bitpop",
    "boyband",
    "british hip hop",
    "bubblegum bass",
    "chill house",
    "chillout r&b",
    "cloud rap",
    "country house",
    "countrystep",
    "dance",
    "dance house",
    "danish poprock",
    "detroit trap",
    "drill",
    "electro pop",
    "hardcore rap",
    "hip-house",
    "hyperpop",
    "industrial pop",
    "instrumental",
    "jersey club",
    "liquid drum and bass",
    "melodic rap",
    "neo-soul",
    "neoperreo",
    "plugg",
    "pop edm",
    "pop in spanish",
    "pop reggae",
    "pop soul",
    "power ballad",
    "progressive pop",
    "rnb contemporary",
    "sophisti pop",
    "soul pop",
    "southern rap",
    "spiritual jazz",
    "surf punk",
    "trap",
    "trap pop",
    "tropical house",
    "uk bass",
    "uk funky",
    "underground hip-hop",
    "urban pop",
    "urbano latino",
    "wonky",
]


def fetch(url: str) -> str:
    with urllib.request.urlopen(url, timeout=30) as r:
        return r.read().decode("utf-8", errors="ignore")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "-t",
        "--tags-file",
        help="file of the library's unique raw last.fm tags (optional)",
    )
    ap.add_argument("-o", "--output", default="genres-extra.txt")
    args = ap.parse_args()

    beets_wl = {
        line.strip().lower()
        for line in fetch(BEETS_URL).splitlines()
        if line.strip() and not line.startswith("#")
    }
    spotify = {
        m.group(1).strip().lower()
        for line in fetch(SPOTIFY_URL).splitlines()
        if (m := re.match(r"^\d+\.\s+(.+?)\s*$", line.strip()))
    }
    print(f"beets base: {len(beets_wl)} | spotify: {len(spotify)}")

    tier1 = sorted(n for n in spotify - beets_wl if n not in JUNK_BLACKLIST)
    tier2 = sorted(t for t in REGIONAL if t not in beets_wl and t not in tier1)
    tier3 = sorted(
        t
        for t in LIBRARY_DERIVED
        if t not in beets_wl and t not in tier1 and t not in tier2
    )

    if args.tags_file:
        with open(args.tags_file) as tags_file:
            user_tags = {line.strip().lower() for line in tags_file if line.strip()}
        missing = sorted(user_tags - beets_wl - spotify)
        print(
            f"user tags: {len(user_tags)} | covered by beets+spotify: {len(user_tags - set(missing))} "
            f"| NOT covered (review manually): {len(missing)}"
        )

    supplement = sorted(set(tier1) | set(tier2) | set(tier3))
    with open(args.output, "w") as f:
        f.write("# Genre whitelist supplement for the Beets addon\n")
        f.write(
            "# Merged with beets' bundled genres.txt at startup (whitelist: true)\n"
        )
        f.write(
            "# Sources: Spotify/EveryNoise catalog + regional descriptors + library-derived\n\n"
        )
        f.write("\n".join(supplement) + "\n")
    print(f"supplement written: {len(supplement)} genres -> {args.output}")
    print(
        f"  tier1 spotify: {len(tier1)} | tier2 regional: {len(tier2)} | tier3 library: {len(tier3)}"
    )


if __name__ == "__main__":
    main()
