{
  description = "A utility to easily take screenshots in Hyprland using your mouse";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "hyprshot";
          version = "1.3.0";

          src = ./.;

          nativeBuildInputs = [ pkgs.makeWrapper ];

          buildInputs = [
            pkgs.bash
            pkgs.grim
            pkgs.slurp
            pkgs.jq
            pkgs.wl-clipboard
            pkgs.libnotify
            pkgs.hyprpicker
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin
            install -Dm755 hyprshot $out/bin/hyprshot

            wrapProgram $out/bin/hyprshot \
              --prefix PATH : ${pkgs.lib.makeBinPath [
                pkgs.grim
                pkgs.slurp
                pkgs.jq
                pkgs.wl-clipboard
                pkgs.libnotify
                pkgs.hyprpicker
              ]}

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "A utility to easily take screenshots in Hyprland using your mouse";
            homepage = "https://github.com/nevimmu/Hyprshot";
            license = licenses.gpl3Only;
            maintainers = [ ];
            platforms = platforms.linux;
            mainProgram = "hyprshot";
          };
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/hyprshot";
        };
      }
    );
}
