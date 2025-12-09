# Inframan

A CLI tool that bridges [Terranix](https://terranix.org/) (Infrastructure as Nix) and [Colmena](https://colmena.cli.rs/) (NixOS deployment), enabling declarative infrastructure provisioning and NixOS configuration management in a unified workflow.

## Overview

Inframan orchestrates the complete lifecycle of NixOS infrastructure:

1. **Infrastructure Provisioning** - Uses Terranix to define infrastructure as Nix, compiled to Terraform JSON and applied via OpenTofu
2. **NixOS Deployment** - Automatically deploys NixOS configurations to provisioned instances using Colmena

## Features

- 🔧 **Pure Nix Configuration** - Define both infrastructure and machine configuration in Nix
- 🚀 **Single Command Workflow** - Provision and deploy with simple CLI commands
- 🔄 **Dynamic Target Discovery** - Automatically reads instance IPs from OpenTofu state
- 📦 **Nix Flake Integration** - Use `inframan.lib.mkRunner` to create project-specific runners

## Installation

### Using Nix Flakes

```bash
# Run directly
nix run github:iivel-inc/inframan

# Or add to your flake inputs
{
  inputs.inframan.url = "github:iivel-inc/inframan";
}
```

### Development Shell

```bash
git clone https://github.com/iivel-inc/inframan
cd inframan
nix develop
```

## Usage

### Quick Start

1. **Create your project** with infrastructure and machine configurations (see [example/](./example/))

2. **Set up your flake** using `inframan.lib.mkRunner`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    inframan.url = "github:iivel-inc/inframan";
  };

  outputs = { self, nixpkgs, inframan, ... }: {
    apps.x86_64-linux.default = {
      type = "app";
      program = "${inframan.lib.mkRunner {
        system = "x86_64-linux";
        infraConfig = ./infrastructure.nix;
        machineConfig = ./machine.nix;
      }}/bin/runner";
    };
  };
}
```

3. **Provision infrastructure**:

```bash
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
nix run . -- infra
```

4. **Deploy NixOS configuration**:

```bash
nix run . -- deploy
```

### Commands

| Command | Description |
|---------|-------------|
| `inframan infra` | Apply infrastructure using Terranix and OpenTofu |
| `inframan deploy` | Deploy NixOS configuration using Colmena |

### Environment Variables

| Variable | Description |
|----------|-------------|
| `INFRA_CONFIG_JSON` | Path to Terranix-generated JSON file (set by runner) |
| `NIXOS_MODULE_PATH` | Path to NixOS configuration module (set by runner) |
| `AWS_ACCESS_KEY_ID` | AWS credentials for infrastructure provisioning |
| `AWS_SECRET_ACCESS_KEY` | AWS credentials for infrastructure provisioning |

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ infrastructure  │────▶│    Terranix     │────▶│  config.tf.json │
│     .nix        │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                                         ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   machine.nix   │────▶│    Colmena      │────▶│  NixOS Instance │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                 ▲
                                 │ IP from tofu output
                        ┌────────┴────────┐
                        │    OpenTofu     │
                        │                 │
                        └─────────────────┘
```

## Example

See the [example/](./example/) directory for a complete working example that:

- Provisions an AWS EC2 instance running NixOS
- Deploys an nginx web server configuration
- Demonstrates the full inframan workflow

## Requirements

- Nix 2.4+ with flakes enabled
- AWS credentials (for the example)
- SSH key for instance access

## License

MIT License - see [LICENSE](./LICENSE) for details.

