# NixOS configuration module for AWS Account 1 (Production)
# This is deployed via Colmena after infrastructure is provisioned
{ config, pkgs, lib, ... }:

{
  # System basics
  system.stateVersion = "24.05";

  # Boot configuration for AWS
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "inframan-account1-prod";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  # SSH access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Root user SSH key (add your public key here)
  users.users.root.openssh.authorizedKeys.keys = [
    # "ssh-ed25519 AAAA... your-key-here"
  ];

  # Production web server with nginx
  services.nginx = {
    enable = true;
    virtualHosts."default" = {
      default = true;
      root = pkgs.writeTextDir "index.html" ''
        <!DOCTYPE html>
        <html>
          <head><title>Production - Account 1</title></head>
          <body style="font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px;">
            <h1 style="color: #2563eb;">🚀 Production Environment (Account 1)</h1>
            <p>This NixOS server is running in <strong>AWS Account 1</strong> (us-east-1)</p>
            <h2>Deployed with Inframan:</h2>
            <ul>
              <li>Terranix - Infrastructure as Nix</li>
              <li>OpenTofu - Infrastructure provisioning</li>
              <li>Colmena - NixOS deployment</li>
              <li>Inframan - The Go bridge connecting them</li>
            </ul>
            <div style="background: #dbeafe; padding: 15px; border-radius: 5px; margin-top: 20px;">
              <strong>Environment:</strong> Production<br>
              <strong>Region:</strong> us-east-1<br>
              <strong>Project:</strong> account1
            </div>
          </body>
        </html>
      '';
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    curl
    wget
  ];

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

