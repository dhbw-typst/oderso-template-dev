{
  description = "A nix flake for a typst environment";

  # Flake inputs
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  # Flake outputs
  outputs = inputs:
    let
      # The systems supported for this flake
      supportedSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forEachSupportedSystem = f: inputs.nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import inputs.nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShellNoCC {
          # The Nix packages provided in the environment
          packages = with pkgs; [
            typst
            typstyle
            tinymist
          ];

          # Set any environment variables for your dev shell
          env = { };

          # Add any shell logic you want executed any time the environment is activated
          shellHook = ''
            # Unset SOURCE_DATE_EPOCH as else #datetime.today() will be 01.01.1980
            unset SOURCE_DATE_EPOCH
          '';
        };
      });
    };
}
