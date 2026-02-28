FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install everything in ONE layer
RUN dpkg --add-architecture i386 && \
    apt update && \
    apt install -y \
        wine \
        qemu-kvm \
        xz-utils \
        dbus-x11 \
        curl \
        firefox-esr \
        git \
        xfce4 \
        xfce4-terminal \
        tightvncserver \
        wget && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Download noVNC
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz && \
    tar -xvf v1.2.0.tar.gz && \
    mv noVNC-1.2.0 /noVNC

# Setup VNC
RUN mkdir -p /root/.vnc && \
    echo 'admin123@a' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo '#!/bin/bash\n\
export MOZ_FAKE_NO_SANDBOX=1\n\
dbus-launch xfce4-session &' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Startup script
RUN echo '#!/bin/bash\n\
vncserver :1 -geometry 1360x768\n\
cd /noVNC\n\
./utils/launch.sh --vnc localhost:5901 --listen 8900' > /start.sh && \
    chmod +x /start.sh

EXPOSE 8900

CMD ["/start.sh"]
