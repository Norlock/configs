FROM archlinux

COPY scripts/install.lua /home

RUN pacman -Syu  --noconfirm
RUN pacman -S --noconfirm lua sudo
CMD journalctl -f
