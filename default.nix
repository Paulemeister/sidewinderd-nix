{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation {
  pname = "sidewinderd";
  version = "0.4.4";

  src = pkgs.fetchFromGitHub {
    owner = "tolga9009";
    repo = "sidewinderd";
    rev = "0.4.4";
    hash = "sha256-vlmL/Wz31/xAmKV5hxQ3H5eQOCZRFKbqRjRCxQn4pdo=";
  };

  nativeBuildInputs = [pkgs.cmake];
  buildInputs = with pkgs; [libconfig tinyxml-2 udev];

  #  env = {
  #    PREFIX = "${placeholder "out"}";
  #  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./src/sidewinderd $out/bin/sidewinderd
    #cp $src/etc/sidewinderd.conf $out/etc/sidewinderd.conf
    #cp ./src/sidewinderd.service $out/etc/systemd/system/sidewinderd.service
    runHook postInstall
  '';

  meta = with pkgs; {
    description = "Linux support for Microsoft SideWinder X4 / X6 and Logitech G103 / G105 / G710+.";
    longDescription = ''
      This project provides support for gaming peripherals under Linux.
      It was originally designed for the Microsoft SideWinder X4,
      but we have extended support for more keyboards.
      Our goal is to create a framework-like environment for rapid driver development under Linux.
    '';
    homepage = "https://github.com/tolga9009/sidewinderd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [paulemeister];
    platforms = lib.platforms.linux;
  };
}
