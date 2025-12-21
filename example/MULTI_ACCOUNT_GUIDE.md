# Multi-Account AWS Setup Guide

## Quick Reference

| Aspect | Account 1 (Production) | Account 2 (Development) |
|--------|------------------------|-------------------------|
| **Project Name** | `account1` | `account2` |
| **AWS Region** | `us-east-1` | `us-west-2` |
| **Environment** | Production | Development |
| **Infrastructure File** | `infrastructure-account1.nix` | `infrastructure-account2.nix` |
| **Machine Config** | `machine-account1.nix` | `machine-account2.nix` |
| **Hostname** | `inframan-account1-prod` | `inframan-account2-dev` |
| **State Directory** | `.inframan/account1/` | `.inframan/account2/` |
| **Run Command** | `nix run .#account1` | `nix run .#account2` |

## Commands Cheat Sheet

### Account 1 (Production)

```bash
# Provision infrastructure
nix run .#account1 -- infra

# Deploy NixOS configuration
nix run .#account1 -- deploy

# Check Terraform state
cd .inframan/account1/terraform
terraform show
```

### Account 2 (Development)

```bash
# Provision infrastructure
nix run .#account2 -- infra

# Deploy NixOS configuration
nix run .#account2 -- deploy

# Check Terraform state
cd .inframan/account2/terraform
terraform show
```

## Credential Setup

### Option 1: Using terraform.tfvars (Recommended)

Create separate tfvars files for each account:

```bash
# Account 1
mkdir -p .inframan/account1/terraform
cat > .inframan/account1/terraform/terraform.tfvars <<EOF
aws_access_key = "AKIA...account1..."
aws_secret_key = "secret-for-account1"
ssh_public_key = "ssh-ed25519 AAAA... your-key"
EOF

# Account 2
mkdir -p .inframan/account2/terraform
cat > .inframan/account2/terraform/terraform.tfvars <<EOF
aws_access_key = "AKIA...account2..."
aws_secret_key = "secret-for-account2"
ssh_public_key = "ssh-ed25519 AAAA... your-key"
EOF
```

### Option 2: Using Environment Variables

You can also pass credentials via environment variables when running terraform:

```bash
# For Account 1
cd .inframan/account1/terraform
TF_VAR_aws_access_key="AKIA..." \
TF_VAR_aws_secret_key="secret..." \
TF_VAR_ssh_public_key="ssh-ed25519 AAAA..." \
terraform apply

# For Account 2
cd .inframan/account2/terraform
TF_VAR_aws_access_key="AKIA..." \
TF_VAR_aws_secret_key="secret..." \
TF_VAR_ssh_public_key="ssh-ed25519 AAAA..." \
terraform apply
```

## Key Differences Between Accounts

### Infrastructure Differences

**Account 1 (Production):**
- Region: `us-east-1`
- Security Group: `inframan-account1-sg`
- Key Pair: `inframan-account1-deployer`
- Instance Name: `inframan-account1-instance`
- Tags: `Environment = "production"`

**Account 2 (Development):**
- Region: `us-west-2`
- Security Group: `inframan-account2-sg`
- Key Pair: `inframan-account2-deployer`
- Instance Name: `inframan-account2-instance`
- Tags: `Environment = "development"`

### Machine Configuration Differences

**Account 1 (Production):**
- Hostname: `inframan-account1-prod`
- Web page: Blue theme, production branding
- Packages: Standard set (vim, htop, git, curl, wget)

**Account 2 (Development):**
- Hostname: `inframan-account2-dev`
- Web page: Green theme, development branding
- Packages: Extended set (includes tmux, jq for development)

## Workflow Example

Here's a typical workflow for managing both accounts:

```bash
# 1. Set up credentials (one time)
mkdir -p .inframan/account{1,2}/terraform
# ... create terraform.tfvars files as shown above

# 2. Add SSH keys to machine configs
vim machine-account1.nix  # Add your SSH key
vim machine-account2.nix  # Add your SSH key

# 3. Deploy to production (Account 1)
nix run .#account1 -- infra
nix run .#account1 -- deploy

# 4. Test in development (Account 2)
nix run .#account2 -- infra
nix run .#account2 -- deploy

# 5. Verify both are running
curl http://$(cd .inframan/account1/terraform && terraform output -raw public_ip)
curl http://$(cd .inframan/account2/terraform && terraform output -raw public_ip)

# 6. Make changes to development first
vim machine-account2.nix  # Make changes
nix run .#account2 -- deploy  # Test in dev

# 7. If successful, apply to production
vim machine-account1.nix  # Apply same changes
nix run .#account1 -- deploy  # Deploy to prod
```

## Security Best Practices

1. **Never commit credentials** - Add `.inframan/*/terraform/terraform.tfvars` to `.gitignore`
2. **Use IAM roles** - Consider using AWS IAM roles instead of access keys when possible
3. **Separate AWS accounts** - Use AWS Organizations to properly separate production and development
4. **Restrict security groups** - Update the `0.0.0.0/0` CIDR blocks to your specific IP ranges
5. **Enable MFA** - Use multi-factor authentication on both AWS accounts
6. **Rotate credentials** - Regularly rotate AWS access keys

## Extending to More Accounts

To add a third account (e.g., staging):

1. Create `infrastructure-account3.nix` (copy and modify from account1 or account2)
2. Create `machine-account3.nix` (copy and modify from account1 or account2)
3. Add to `flake.nix`:

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

4. Run with `nix run .#account3 -- infra` and `nix run .#account3 -- deploy`

