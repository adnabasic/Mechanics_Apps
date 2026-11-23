FROM --platform=linux/amd64 python:3.7-slim-bullseye

# Node.js 12 - Bokeh braucht es, um die LaTeX-Erweiterungen (shared/*.ts) zu uebersetzen
RUN apt-get update && apt-get install -y --no-install-recommends curl xz-utils ca-certificates \
 && curl -fsSL https://nodejs.org/dist/v12.22.12/node-v12.22.12-linux-x64.tar.xz \
    | tar -xJ -C /usr/local --strip-components=1 \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

WORKDIR /app
COPY . /app

# OpenShift startet Container mit zufaelliger User-ID -> Gruppe 0 muss schreiben duerfen
RUN chgrp -R 0 /app && chmod -R g=u /app
ENV HOME=/tmp \
    APPLIST=appnames.conf \
    PUBLIC_HOST=localhost:5006
USER 1001
EXPOSE 5006

CMD bokeh serve $(cat $APPLIST) \
    --address 0.0.0.0 --port 5006 \
    --allow-websocket-origin=$PUBLIC_HOST \
    --use-xheaders
