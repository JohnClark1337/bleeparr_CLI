import sys

from faster_whisper import WhisperModel

sizes = sys.argv[1:] or ["small.en", "medium.en"]

for size in sizes:
    print(f"Downloading faster-whisper model: {size}", flush=True)
    WhisperModel(size, device="cpu", compute_type="int8")
    print(f"OK: {size}", flush=True)

print("Model prefetch complete.", flush=True)