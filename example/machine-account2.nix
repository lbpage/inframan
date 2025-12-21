# NixOS configuration module for AWS Account 2 (Development)
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
  networking.hostName = "inframan-account2-dev";
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

  # Development web server with nginx
  services.nginx = {
    enable = true;
    virtualHosts."default" = {
      default = true;
      root = pkgs.writeTextDir "index.html" ''
        <!DOCTYPE html>
        <html>
          <head><title>Development - Account 2</title></head>
          <body style="font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px;">
            <h1 style="color: #16a34a;">🧪 Development Environment (Account 2)</h1>
            <p>This NixOS server is running in <strong>AWS Account 2</strong> (us-west-2)</p>
            <h2>Deployed with Inframan:</h2>
            <ul>
              <li>Terranix - Infrastructure as Nix</li>
              <li>OpenTofu - Infrastructure provisioning</li>
              <li>Colmena - NixOS deployment</li>
              <li>Inframan - The Go bridge connecting them</li>
            </ul>
            <div style="background: #dcfce7; padding: 15px; border-radius: 5px; margin-top: 20px;">
              <strong>Environment:</strong> Development<br>
              <strong>Region:</strong> us-west-2<br>
              <strong>Project:</strong> account2
            </div>
          </body>
        </html>
      '';
    };
  };

  # System packages (more dev tools for development environment)
  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    curl
    wget
    tmux
    jq
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

