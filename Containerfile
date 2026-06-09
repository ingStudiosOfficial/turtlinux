# Fedora Kinoite 45
FROM quay.io/fedora-ostree-desktops/kinoite:45

# Setup mirrors
RUN dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-rawhide.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-rawhide.noarch.rpm \
    && dnf clean all

# Install packages
RUN dnf install -y libreoffice java-latest-openjdk kdenlive konsole kcalc kate fastfetch discord htop vim git && dnf clean all

# Copy turtagent binary to TurtLinux
#COPY turtagent/bin/turtagent /usr/bin/turtagent
#RUN chmod +x /usr/bin/turtagent

# NOTE: Add more steps for turtagent if needed

# Copy the autostart config into the global system directory
#COPY config/turtagent.desktop /etc/xdg/autostart/

# Run the bootc linter to ensure compatibility
RUN bootc container lint
