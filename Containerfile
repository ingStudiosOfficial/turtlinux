# TURTLINUX CONTAINERFILE
# -----------------------
# NOTE: Comment/uncomment ONLY if you think it will not disintegrate.
#       Or else GitHub Actions will die.

# Fedora Kinoite 45
FROM quay.io/fedora-ostree-desktops/kinoite:45

# [ PACKAGES ]
RUN dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-rawhide.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-rawhide.noarch.rpm \
    && dnf clean all
RUN dnf install -y libreoffice java-latest-openjdk kdenlive konsole kcalc kate fastfetch discord htop vim git && dnf clean all

# [ TURTAGENT ]
#COPY turtagent/bin/turtagent /usr/bin/turtagent
#RUN chmod +x /usr/bin/turtagent
# NOTE: Add more steps for turtagent if needed
#COPY config/turtagent.desktop /etc/xdg/autostart/

# [ BRANDING ]
RUN echo "turtlinux" > /etc/hostname
COPY branding/os-release /etc/os-release
COPY branding/os-release /usr/lib/os-release
RUN mkdir -p /usr/share/backgrounds/turtlinux
#COPY branding/wallpaper.png /usr/share/backgrounds/turtlinux/default.png
#COPY branding/sddm-theme/ /usr/share/sddm/themes/turtlinux/
#RUN echo -e "[Theme]\nCurrent=turtlinux" > /etc/sddm.conf.d/branding.conf
RUN mkdir -p /usr/share/sounds/turtlinux
COPY branding/startup.wav /usr/share/sounds/turtlinux/startup.wav
COPY config/startup.desktop /etc/xdg/autostart/
COPY branding/turtlinux.png /usr/share/pixmaps/turtlinux.png
COPY branding/turtlinux.png /usr/share/icons/hicolor/256x256/apps/turtlinux.png

# [ FASTFETCH & NEOFETCH ]
RUN mkdir -p /etc/fastfetch /etc/neofetch
COPY config/fastfetch.jsonc /etc/fastfetch/config.jsonc
COPY config/neofetch.conf /etc/neofetch/config.conf

# [ FINISH ]
RUN bootc container lint
