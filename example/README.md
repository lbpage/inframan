# Inframan Example - Multi-Account AWS Setup

This example demonstrates how to use inframan to manage infrastructure across **two separate AWS accounts**, each with its own EC2 instance running NixOS.

## Scenario

You have two AWS accounts:
- **Account 1** (Production) - Running in `us-east-1`
- **Account 2** (Development) - Running in `us-west-2`

Each account gets its own isolated infrastructure and deployment configuration.

## Files

### Account 1 (Production)
- `infrastructure-account1.nix` - Terranix configuration for Account 1 (us-east-1)
- `machine-account1.nix` - NixOS module for production instance

### Account 2 (Development)
- `infrastructure-account2.nix` - Terranix configuration for Account 2 (us-west-2)
- `machine-account2.nix` - NixOS module for development instance

### Shared
- `flake.nix` - Nix flake defining both account runners
- `infrastructure.nix` - Legacy single-account config (kept for reference)
- `machine.nix` - Legacy single-account config (kept for reference)

## Prerequisites

1. **Two AWS accounts** with separate credentials
2. **SSH key** - Have an SSH public key ready for instance access
3. **Nix with flakes** - Nix 2.4+ with experimental features enabled

## Usage

### 1. Set up environment variables

Create separate credential files for each account:

```bash
# Account 1 (Production) credentials
cat > .inframan/account1/terraform/terraform.tfvars <<EOF
aws_access_key = "AKIA..."
aws_secret_key = "your-account1-secret"
ssh_public_key = "ssh-ed25519 AAAA... your-key"
EOF

# Account 2 (Development) credentials
cat > .inframan/account2/terraform/terraform.tfvars <<EOF
aws_access_key = "AKIA..."
aws_secret_key = "your-account2-secret"
ssh_public_key = "ssh-ed25519 AAAA... your-key"
EOF
```

**Note:** You'll need to create the `.inframan/account1/terraform/` and `.inframan/account2/terraform/` directories first, or let inframan create them on the first run.

### 2. Add SSH keys to machine configs

Edit both `machine-account1.nix` and `machine-account2.nix` to add your SSH public key:

```nix
users.users.root.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA... your-key-here"
];
```

### 3. Provision Account 1 (Production)

```bash
# From the example directory
nix run .#account1 -- infra
```

This will:
- Compile `infrastructure-account1.nix` to `config.tf.json` via Terranix
- Store state in `.inframan/account1/terraform/`
- Provision EC2 instance in Account 1 (us-east-1)

### 4. Deploy to Account 1

```bash
nix run .#account1 -- deploy
```

This will:
- Read the instance IP from Account 1's terraform output
- Deploy the production NixOS configuration
- Visit `http://<account1-ip>` to see the production page

### 5. Provision Account 2 (Development)

```bash
nix run .#account2 -- infra
```

This will:
- Compile `infrastructure-account2.nix` to `config.tf.json` via Terranix
- Store state in `.inframan/account2/terraform/`
- Provision EC2 instance in Account 2 (us-west-2)

### 6. Deploy to Account 2

```bash
nix run .#account2 -- deploy
```

This will:
- Read the instance IP from Account 2's terraform output
- Deploy the development NixOS configuration
- Visit `http://<account2-ip>` to see the development page

### 7. Verify

After deployment, you'll have:
- **Account 1**: Production instance in us-east-1 with blue-themed page
- **Account 2**: Development instance in us-west-2 with green-themed page

Each account is completely isolated with its own Terraform state and Colmena configuration.

## Project Structure

After running both accounts, your `.inframan/` directory will look like:

```
.inframan/
├── account1/
│   ├── terraform/
│   │   ├── config.tf.json          # Generated from infrastructure-account1.nix
│   │   ├── terraform.tfstate       # Account 1 state
│   │   └── terraform.tfvars        # Account 1 credentials
│   └── colmena/
│       └── hive.nix                # Generated Colmena config for Account 1
└── account2/
    ├── terraform/
    │   ├── config.tf.json          # Generated from infrastructure-account2.nix
    │   ├── terraform.tfstate       # Account 2 state
    │   └── terraform.tfvars        # Account 2 credentials
    └── colmena/
        └── hive.nix                # Generated Colmena config for Account 2
```

## Customization

### Different instance types per account

Edit the respective infrastructure file:

**Account 1 (Production):**
```nix
# infrastructure-account1.nix
variable.instance_type.default = "t3.small";
```

**Account 2 (Development):**
```nix
# infrastructure-account2.nix
variable.instance_type.default = "t3.micro";
```

### Additional services

Add services to the respective machine configuration:

```nix
# machine-account1.nix (production)
services.postgresql.enable = true;
services.redis.enable = true;
```

### Different regions

Each account can use different AWS regions (already configured):
- Account 1: `us-east-1`
- Account 2: `us-west-2`

### Adding more accounts

To add a third account, extend `flake.nix`:

```nix
packages.${system}.account3 = inframan.lib.mkRunner {
  inherit system;
  infraConfig = ./infrastructure-account3.nix;
  machineConfig = ./machine-account3.nix;
  projectName = "account3";
};

apps.${system}.account3 = {
  type = "app";
  program = "${self.packages.${system}.account3}/bin/runner";
};
```

## Cleanup

To destroy the infrastructure for each account:

```bash
# Destroy Account 1 (Production)
cd .inframan/account1/terraform
terraform destroy

# Destroy Account 2 (Development)
cd .inframan/account2/terraform
terraform destroy
```

## Key Benefits of This Setup

1. **Complete Isolation** - Each AWS account has its own Terraform state, preventing accidental cross-account changes
2. **Different Regions** - Account 1 uses us-east-1, Account 2 uses us-west-2
3. **Separate Credentials** - Each account uses its own AWS credentials stored in separate tfvars files
4. **Independent Deployments** - Deploy to production without affecting development and vice versa
5. **Clear Organization** - `.inframan/account1/` and `.inframan/account2/` keep everything organized

## Troubleshooting

### Credentials not found

Make sure you've created the `terraform.tfvars` files in the correct locations:
- `.inframan/account1/terraform/terraform.tfvars`
- `.inframan/account2/terraform/terraform.tfvars`

### SSH connection fails

Ensure your SSH public key is added to both:
- `machine-account1.nix`
- `machine-account2.nix`

### Wrong AWS account

Double-check that you're using the correct credentials in each account's `terraform.tfvars` file.

