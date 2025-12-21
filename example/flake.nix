{
  description = "Example usage of inframan for managing multiple AWS accounts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    inframan.url = "path:..";  # In real usage: github:your-org/inframan
  };

  outputs = { self, nixpkgs, inframan, ... }:
    let
      system = "x86_64-linux";
    in
    {
      # Account 1: Production AWS account
      packages.${system}.account1 = inframan.lib.mkRunner {
        inherit system;
        infraConfig = ./infrastructure-account1.nix;
        machineConfig = ./machine-account1.nix;
        projectName = "account1";
      };

      apps.${system}.account1 = {
        type = "app";
        program = "${self.packages.${system}.account1}/bin/runner";
      };

      # Account 2: Development AWS account
      packages.${system}.account2 = inframan.lib.mkRunner {
        inherit system;
        infraConfig = ./infrastructure-account2.nix;
        machineConfig = ./machine-account2.nix;
        projectName = "account2";
      };

      apps.${system}.account2 = {
        type = "app";
        program = "${self.packages.${system}.account2}/bin/runner";
      };

      # Default points to account1 for convenience
      packages.${system}.default = self.packages.${system}.account1;
      apps.${system}.default = self.apps.${system}.account1;
    };
}

