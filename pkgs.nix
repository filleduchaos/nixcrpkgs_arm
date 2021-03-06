{ crossenv }:
let pkgs =
rec {
  recurseForDerivations = true;
  inherit (crossenv) binutils gcc;

  hello = import ./pkgs/hello {
    inherit crossenv;
  };

  hello_cpp = import ./pkgs/hello_cpp {
    inherit crossenv;
  };

  usbview = import ./pkgs/usbview {
    inherit crossenv;
  };

  devcon = import ./pkgs/devcon {
    inherit crossenv;
  };

  pdcurses = import ./pkgs/pdcurses {
    inherit crossenv;
  };
  pdcurses_examples = pdcurses.examples;

  readline = import ./pkgs/readline {
    inherit crossenv;
    curses = pdcurses;
  };

  expat = import ./pkgs/expat {
    inherit crossenv;
  };

  zlib = import ./pkgs/zlib {
    inherit crossenv;
  };

  gdb = import ./pkgs/gdb {
    inherit crossenv expat;
    curses = pdcurses;
  };

  libudev = import ./pkgs/libudev {
    inherit crossenv;
  };

  libusbp = import ./pkgs/libusbp {
    inherit crossenv libudev;
  };
  libusbp_examples = libusbp.examples;
  libusbp_license_fragment = libusbp.license_fragment;

  p-load = import ./pkgs/p-load {
    inherit crossenv libusbp;
  };

  angle = import ./pkgs/angle {
    inherit crossenv gdb;
  };

  xcb-proto = import ./pkgs/xcb-proto {
    inherit crossenv;
  };

  xorg-macros = import ./pkgs/xorg-macros {
    inherit crossenv;
  };

  xproto = import ./pkgs/xproto {
    inherit crossenv xorg-macros;
  };

  libxau = import ./pkgs/libxau {
    inherit crossenv xorg-macros xproto;
  };

  libxcb = import ./pkgs/libxcb {
    inherit crossenv xcb-proto libxau;
  };
  libxcb_examples = libxcb.examples;

  xcb-util = import ./pkgs/xcb-util {
    inherit crossenv libxcb;
  };

  xcb-util-image = import ./pkgs/xcb-util-image {
    inherit crossenv libxcb xcb-util;
  };

  xcb-util-keysyms = import ./pkgs/xcb-util-keysyms {
    inherit crossenv libxcb;
  };

  xcb-util-renderutil = import ./pkgs/xcb-util-renderutil {
    inherit crossenv libxcb;
  };

  xcb-util-wm = import ./pkgs/xcb-util-wm {
    inherit crossenv libxcb;
  };

  xtrans = import ./pkgs/xtrans {
    inherit crossenv;
  };

  xextproto = import ./pkgs/xextproto {
    inherit crossenv;
  };

  inputproto = import ./pkgs/inputproto {
    inherit crossenv;
  };

  kbproto = import ./pkgs/kbproto {
    inherit crossenv;
  };

  fixesproto = import ./pkgs/fixesproto {
    inherit crossenv xorg-macros xextproto;
  };

  libx11 = import ./pkgs/libx11 {
    inherit crossenv xorg-macros xproto libxcb xtrans;
    inherit xextproto inputproto kbproto;
  };

  libxext = import ./pkgs/libxext {
    inherit crossenv xproto xextproto libx11;
  };

  libxfixes = import ./pkgs/libxfixes {
    inherit crossenv xproto xextproto fixesproto libx11;
  };

  libxi = import ./pkgs/libxi {
    inherit crossenv xproto xextproto inputproto;
    inherit libx11 libxext libxfixes;
  };

  libxall = import ./pkgs/libxall {
    inherit crossenv;
    libs = [
      xcb-proto xorg-macros xproto libxau libxcb
      xcb-util xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm
      xtrans xextproto inputproto kbproto fixesproto
      libx11 libxext libxfixes libxi
    ];
  };

  at-spi2-headers = import ./pkgs/at-spi2-headers {
    inherit crossenv;
  };

  dejavu-fonts = import ./pkgs/dejavu-fonts {
    inherit crossenv;
  };

  qt = import ./pkgs/qt {
    inherit crossenv libudev libxall at-spi2-headers dejavu-fonts;
  };
  qt_examples = qt.examples;
  qt_license_fragment = qt.license_fragment;

  open-zwave = import ./pkgs/open-zwave {
    inherit crossenv;
  };

  pavr2 = import ./pkgs/pavr2 {
    inherit crossenv libusbp qt;
  };

  tic = import ./pkgs/tic {
    inherit crossenv libusbp qt;
  };
};
in pkgs
