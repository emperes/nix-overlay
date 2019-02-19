
{ stdenv, lib, fetchurl
, dpkg
, alsaLib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk_pixbuf
, glib
, gnome2
, gnome3
, gtk3
, gtk2
, libuuid
, libX11
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrandr
, libXrender
, libXScrnSaver
, libXtst
, nspr
, nss
, pango
, udev
, xorg
, zlib
, xdg_utils
, wrapGAppsHook
}:

let rpath = lib.makeLibraryPath [
    alsaLib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk_pixbuf
    glib
    gnome2.GConf
    gtk3
    gtk2
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libuuid
    nspr
    nss
    pango
    udev
    xdg_utils
    xorg.libxcb
    zlib
];


in stdenv.mkDerivation rec {
    mirror = https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/;
    name = "yandex-browser-beta";
    version = "_19.1.0.2494-1";
    arch = "_amd64";
    file = ".deb";
    src = fetchurl {
    url = "${mirror}${name}${version}${arch}${file}";
    sha256 = "8306A0347F92332DC96380065BE399C763DD5BA775AE53D76767478FD75C3415"; };

    dontConfigure = true;
    dontBuild = true;
    dontPatchELF = true;
    #dontStrip = true;

    nativeBuildInputs = [ dpkg wrapGAppsHook ];

    buildInputs = [ glib ];
    phases = [ "installPhase" ];

    installPhase = ''
    ar xv $src
    tar xvf data.tar.xz
    mkdir -p $out && mkdir "$out/bin"
    cp -R etc opt usr $out
    export BINARYWRAPPER=$out/opt/*/*/yandex_browser
    substituteInPlace $BINARYWRAPPER \
            --replace /bin/bash ${stdenv.shell}
    ln -sf $BINARYWRAPPER $out/bin/yandex-browser
    ln -s "$out/opt/*/*/yandex_browser" "$out/bin/yandex-browser"
    patchelf \
            --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
            --set-rpath "${rpath}" $out/opt/*/*/yandex-browser
    ln -sf ${xdg_utils}/bin/xdg-settings $out/opt/*/*/xdg-settings
    ln -sf ${xdg_utils}/bin/xdg-mime $out/opt/*/*/xdg-mime
    '';
}
