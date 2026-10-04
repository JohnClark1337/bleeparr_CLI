# Bleeparr CLI v1.4.1

A command-line profanity remover for subtitle-based video cleaning.

---

## 🍴 About this fork

This is a fork of [davidpeele/bleeparr_CLI](https://github.com/davidpeele/bleeparr_CLI),
which is MIT licensed and remains the work of davidpeele — see the Credits
section at the bottom. Everything above the fork note is upstream's README.

Changes added in this fork:

- **Docker packaging** — `Dockerfile`, `docker-compose.yml`, `docker-entrypoint.sh`
  and `fetch_models.py` for building a self-contained image (FFmpeg +
  faster-whisper + subliminal).
- **`--add-audio-track`** — add the censored audio as a new track *inside* the
  original file instead of writing a separate video. All original streams are
  stream-copied, so there is no re-encode and no quality loss.
- **Multi-track support** — one censored track is generated per audio track
  matching `--audio-langs`, each keeping its source channel layout (5.1, stereo,
  …) and language tag.
- **Rescan/replace** — re-running on an already-processed movie rebuilds the
  Bleeparr tracks from the pristine originals instead of appending duplicates,
  so you can iterate on the word list and settings.
- **A real default `swears.txt`** — upstream ships placeholder instruction text
  in this file, which `load_swears()` parses as if every line were a swear word
  (making words like `and`, `with` and `get` triggers). This fork replaces it
  with a usable default list.
- **Python 3.9+ compatibility** via `from __future__ import annotations`, fixing
  the `TypeError: unsupported operand type(s) for |` crash on older Pythons.

---

## 📝 The word list

`swears.txt` decides what gets censored. One word per line, and that is the
whole format:

- **No comments.** A line like `# family friendly` is read as the word `family`
  and `friendly`, because entries are matched against `re.findall(r'\w+', …)`.
- **No multi-word entries.** `damn | darn` (cleanvid's alternates format) will
  never match. Write `damn` and `darn` on separate lines.
- **Exact match only** against the subtitle text, so plurals and variants need
  their own lines (`shit`, `shitty`, `bullshit`).

For broader coverage, drop in
[cleanvid's list](https://github.com/mmguero/cleanvid/blob/main/src/cleanvid/swears.txt)
after stripping its `alternitive` entries down to bare words.

---

## 🆕 What’s New in v1.4.1
- Fixed all FFmpeg path handling (files/folders with spaces now work).
- Removed all `shell=True`; now passing FFmpeg args as safe lists.
- Improved ENOSPC (no space left on device) message with temp-dir suggestion.
- Embedded subtitle detection and extraction run before online searches.
- Added `--subtitle-lang`, `--no-embedded-subs`, and `--dry-run` options.


**Bleeparr_CLI** is an automated profanity censorship tool that intelligently detects and mutes (or beeps over) bad words in video files using subtitles and Whisper AI.

🚀 Built for creators, parents, teachers, and anyone who wants cleaner media.

## What's New in v1.4.0
- Prefer **embedded text subtitles** before online search (subrip/ass/ssa/mov_text/webvtt)
- New flags: `--subtitle-lang`, `--no-embedded-subs`, `--dry-run`
- Friendlier ENOSPC (“no space left on device”) messages with `--temp-dir` suggestion
- Avoid creating `clips/` on dry-run
- Tidied FFmpeg runner (removed duplicate/unreachable code)
- 
## What's New in v1.3

- ✅ Added `--beep` mode to replace mute with a tone
- ✅ Choose tone mode with `--beep-mode words` or `both`
- ✅ Default is mute-only (no tone)
- ✅ New `--temp-dir` option to set location for clip processing
- ✅ Automatically deletes temp clips folder unless `--keep-clips` is set
- ✅ All paths (input, output, temp) are now safe across folders with spaces
- ✅ `swears.txt` is always resolved relative to the script location
---

## ✨ What's New in v1.2

- 🔊 `--beep`: Add a beep tone instead of muting bad words.
- 🎚️ `--beep-mode`: Choose between beeping just the detected words, the full subtitle segments, or both.
- 📁 `--temp-dir`: Choose a custom path for storing temporary clips.
- 📦 `--retain-clips`: Keep the `clips/` folder after processing (default: delete).

---

🆕 Changelog: Bleeparr v1.1

🔊 New Features
- Whisper Multi-Model Fallback: If Whisper Small misses a known bad word, it will retry using Whisper Medium before falling back >
- Flexible Censorship Display: New flag --alert-censoring-off allows disabling asterisk-style censoring for debugging/logging cla>
- More Accurate Clip Extraction: Extracted clips are now tightly trimmed to subtitle segment times, greatly reducing Whisper proc>
- Soft Matching for Swears: Fuzzy matching allows detection even when Whisper uses slight word variations (e.g., ****in vs ****in>
- Better Logging: Each clip now logs the subtitle segment number and which words were found there.
- Cleaner Output: Summary includes mute counts by detection method.

🧰 Improvements
- Boosted audio clip loudness by default (+6dB) for better Whisper accuracy.
- Improved CLI structure and argparse error handling.
- Supports subtitles with multiple bad words in a single line.
---


## ⚙️ Installation

Install system and Python dependencies:

```bash
sudo apt install ffmpeg
pip3 install -r requirements.txt
```

Python requirements include:

- `faster-whisper`
- `ffmpeg-python`
- `srt`
- `subliminal`
- `babelfish`

---

## 🎬 Basic Usage

```bash
python3 bleeparr.py --input yourvideo.mkv
```

This will:
- Auto-extract or download subtitles
- Detect profanity using Whisper + subtitles
- Mute the offending segments
- Output a remuxed `.mkv` with clean audio

---

## ✅ Command-Line Options

| Option                  | Description |
|-------------------------|-------------|
| `--input`               | **Required.** Path to input video file |
| `--subtitle`            | Optional subtitle file (.srt). Auto-detects if not provided |
| `--swears`              | File containing swear words (default: `swears.txt`) |
| `--boost-db`            | dB boost to improve Whisper accuracy (default: 6) |
| `--pre-buffer`          | Mute buffer (ms) before detected word (default: 100) |
| `--post-buffer`         | Mute buffer (ms) after detected word (default: 100) |
| `--output-suffix`       | Suffix for output file name (default: `(edited by Bleeparr)`) |
| `--add-audio-track`     | Add the censored audio as a new track inside the original file instead of writing a separate video. One new track is added per audio track matching `--audio-langs`; originals, subtitles and attachments are stream-copied unchanged. Edited in place, so the drive needs ~1x the movie size free. |
| `--audio-langs`         | Comma-separated language tags to censor with `--add-audio-track` (default: `eng,en,english,und`; `und` covers untagged tracks) |
| `--delete-original`     | Delete the input video after success |
| `--no-keep-subs`        | Delete subtitle file after processing |
| `--alert-censoring-off` | Show uncensored words in terminal/log output |
### New Flags (v1.4.0)

- `--subtitle-lang`  
  Preferred subtitle language code (e.g., `eng`, `spa`, `fra`). Default: `eng`.

- `--no-embedded-subs`  
  Skip checking/extracting embedded subtitles; go straight to external/online.

- `--dry-run`  
  Analyze and plan without creating clips or running FFmpeg; no files are renamed or deleted.

### 🔊 Audio Control Options

| Option             | Description |
|--------------------|-------------|
| `--beep`           | Insert a tone instead of muting |
| `--beep-mode`      | `words` (default), `segments`, or `both` |
| `--bleeptool`      | Pass types to run: `S`, `M`, `FSM` (e.g. `S-M-FSM`) |

### 📁 Folder Options

| Option             | Description |
|--------------------|-------------|
| `--temp-dir`       | Custom directory for storing temporary audio clips |
| `--retain-clips`   | Retain the clips folder after processing |

---

## 📌 Examples
Prefer English subs, try embedded first (default), plan-only:
```bash
python3 bleeparr.py --input "/path/to/video.mkv" --subtitle-lang eng --dry-run

Basic mute (default):
```bash
python3 bleeparr.py --input movie.mkv
```

Use a custom swear list:
```bash
python3 bleeparr.py --input movie.mkv --swears mylist.txt
```

Beep instead of mute:
```bash
python3 bleeparr.py --input movie.mkv --beep
```

Beep full subtitle segments:
```bash
python3 bleeparr.py --input movie.mkv --beep --beep-mode segments
```

Custom clips folder:
```bash
python3 bleeparr.py --input movie.mkv --temp-dir /tmp/clips --retain-clips
```
🧪 Example CLI Usage
```bash
bleeparr --input "My Show.mkv" --beep --beep-mode both
```
🔧 Temp Directory Example
```bash
bleeparr --input "My Show.mkv" --temp-dir /mnt/ramdisk/
```
🗂 Keep Processed Clips (instead of deleting them)
```bash
bleeparr --input "My Show.mkv" --keep-clips
```

### ➕ Adding a censored audio track instead of a new file

```bash
python3 bleeparr.py --input "movie.mkv" --add-audio-track
```

This edits the movie in place: every original stream is stream-copied (no
re-encoding, no quality loss, subtitles and attachments kept) and one new AAC
track is appended **for each audio track that matches `--audio-langs`**, so a
file with both 5.1 and stereo English tracks gains a censored version of each.
The first censored track is marked as the default track; the originals are
demoted but left intact.

Track naming: with more than one censored track the layout is appended to the
title, e.g. `Censored (Bleeparr) (5.1)` and `Censored (Bleeparr) (stereo)`, so
they are easy to tell apart in Plex. Each new track keeps its source language
tag, and 5.1 tracks are encoded at 384 kb/s instead of 192 kb/s.

Selection rules:

- `--audio-langs` takes a comma-separated list of language tags; the default is
  `eng,en,english,und`. `und` is included so untagged tracks (common in MKVs)
  are covered too — pass e.g. `--audio-langs eng` to skip them.
- If no track matches, the first audio track is used anyway and a warning is
  printed, so a run never silently does nothing.
- Commentary in other languages is left alone.

### ♻️ Rescanning an already-processed movie

Just run the same command again. Bleeparr recognises its own tracks by the
`Censored (Bleeparr)` title prefix, drops them, and rebuilds from the pristine
original tracks, so you always end up with exactly one set of censored tracks
no matter how many times you re-run. Whisper therefore always re-reads the
*uncensored* audio, and anything it missed the first time (because of a bigger
`swears.txt`, a higher `--boost-db`, or different flags) gets picked up on the
next pass.

Two caveats:

- Don't rename or re-tag the generated tracks in Plex or mkvtoolnix — if the
  title no longer starts with `Censored (Bleeparr)`, bleeparr will treat the
  track as original and censor it again, giving you duplicates.
- A rescan re-reads the whole movie from the start, so it takes as long as the
  first run. There is no incremental "only look at this track" mode yet.

The result is written to a hidden temp file in the same directory and then
swapped in, so a failed run never leaves a half-written movie. Notes:

- `--delete-original` is ignored in this mode — there is no separate output.
- `--beep` works here too, so you can end up with the original audio plus
  censored muted and/or beeped tracks depending on the flags you pass.
- The output container follows the input (`.mkv` stays Matroska, `.mp4` stays
  MP4), because the file is edited in place.
- Plex/Jellyfin will show the new tracks as selectable audio tracks after it
  re-scans the library.
- The drive needs roughly one copy of the movie size in free space.

---

## 🧠 How It Works

1. Subtitles are parsed to find likely profanity.
2. Whisper runs over extracted clips to verify words.
3. Final audio is remuxed using FFmpeg with volume filters or beeps.

Detection tiers:
- `S`: Whisper Small
- `M`: Whisper Medium (fallback)
- `FSM`: Full Subtitle Mute fallback

---

## ❤️ Credits

Huge thanks to [mmguero](https://github.com/mmguero) for inspiring this project with [cleanvid](https://github.com/mmguero/cleanvid) and [monkeyplug](https://github.com/mmguero/monkeyplug).

This tool is a personal coding journey — it's built with ❤️, powered by [ChatGPT](https://openai.com/chatgpt), and released freely.

---

## 📄 License

MIT License. Use it, fork it, improve it.
