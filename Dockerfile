# syntax=docker/dockerfile:1

FROM python:3.11-slim-bookworm

ARG UID=1000
ARG GID=1000
ARG PREFETCH_MODELS=0

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    HOME=/home/bleeparr \
    HF_HOME=/home/bleeparr/.cache/huggingface \
    HF_HUB_DISABLE_TELEMETRY=1

# ffmpeg/ffprobe are shelled out to by bleeparr.py.
# libgomp1 is a hard requirement of ctranslate2 (faster-whisper).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      ffmpeg \
      libgomp1 \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "$GID" bleeparr \
 && useradd --uid "$UID" --gid "$GID" --create-home --shell /bin/bash bleeparr

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY bleeparr.py swears.txt fetch_models.py docker-entrypoint.sh /app/

RUN chmod +x /app/docker-entrypoint.sh \
 && if [ "$PREFETCH_MODELS" = "1" ]; then python /app/fetch_models.py; fi \
 && mkdir -p /home/bleeparr/.cache \
 && chown -R bleeparr:bleeparr /app /home/bleeparr

USER bleeparr

ENTRYPOINT ["/app/docker-entrypoint.sh"]