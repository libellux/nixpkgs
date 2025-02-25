{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  pkg-config,
  openssl,
  fontconfig,
  nasm,
  libX11,
  libXcursor,
  libXrandr,
  libXi,
  libGL,
  libxkbcommon,
  wayland,
  stdenv,
  gtk3,
  darwin,
  perl,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage rec {
  pname = "oculante";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "woelper";
    repo = "oculante";
    rev = version;
    hash = "sha256-6jow0ektqmEcwFEaJgPqhJPs8LlYmPRLE+zqk1T4wDk=";
  };

  cargoHash = "sha256-0e4FoWhZwq6as0JYHGj1zoAOSr71ztqtWJEY3QXDs9s=";

  nativeBuildInputs = [
    cmake
    pkg-config
    nasm
    perl
    wrapGAppsHook3
  ];

  buildInputs =
    [
      openssl
      fontconfig
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libGL
      libX11
      libXcursor
      libXi
      libXrandr
      gtk3

      libxkbcommon
      wayland
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.libobjc
    ];

  checkFlags = [
    "--skip=bench"
    "--skip=tests::net" # requires network access
    "--skip=tests::flathub"
  ];

  postInstall = ''
    install -Dm444 $src/res/icons/icon.png -t $out/share/icons/hicolor/128x128/apps/
    install -Dm444 $src/res/oculante.desktop -t $out/share/applications
    wrapProgram $out/bin/oculante \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]}
  '';

  meta = with lib; {
    broken = stdenv.hostPlatform.isDarwin;
    description = "Minimalistic crossplatform image viewer written in Rust";
    homepage = "https://github.com/woelper/oculante";
    changelog = "https://github.com/woelper/oculante/blob/${version}/CHANGELOG.md";
    license = licenses.mit;
    mainProgram = "oculante";
    maintainers = with maintainers; [
      dit7ya
      figsoda
    ];
  };
}
