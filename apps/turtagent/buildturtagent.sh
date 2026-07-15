cd ./backend
go build -o ./dist/turtagent-backend ./cmd
cd ../

cd ./overlay
flutter build linux --release

mkdir -p ~/.local/bin
rm -r ~/.local/share/turtagent_overlay/
rm -r ~/.local/bin/turtagent_overlay
mkdir -p ~/.local/share/turtagent_overlay/
mkdir -p ~/.local/bin/

cp -r ./build/linux/x64/release/bundle/* ~/.local/share/turtagent_overlay/
ln -sf ~/.local/share/turtagent_overlay/turtagent_overlay ~/.local/bin/turtagent_overlay
cd ../

cp ./backend/assets/icons/turtagent-plasmoid.svg ~/.local/share/icons/hicolor/scalable/apps/
gtk-update-icon-cache
rm ~/.local/share/applications/dev.ingstudios.turtlinux.turtagent.overlay.desktop
cp -r ./assets/dev.ingstudios.turtlinux.turtagent.overlay.desktop ~/.local/share/applications/dev.ingstudios.turtlinux.turtagent.overlay.desktop