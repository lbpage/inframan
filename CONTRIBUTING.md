# Contributing to Inframan

Thank you for your interest in contributing to Inframan! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Submitting Changes](#submitting-changes)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please be respectful and constructive in all interactions.

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Nix 2.4+** with flakes enabled
- **Go 1.20+** (provided via Nix development shell)
- **Git** for version control
- Basic understanding of:
  - Go programming
  - Nix and NixOS
  - Terraform/Terranix
  - Colmena

### Finding Issues to Work On

- Check the [GitHub Issues](https://github.com/iivel-inc/inframan/issues) page
- Look for issues labeled `good first issue` or `help wanted`
- Feel free to open new issues for bugs or feature requests

## Development Setup

1. **Fork the repository** on GitHub

2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/inframan.git
   cd inframan
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/iivel-inc/inframan.git
   ```

4. **Enter the development shell**:
   ```bash
   nix develop
   ```

   This provides all necessary tools including Go, Terraform, and Colmena.

5. **Build the project**:
   ```bash
   # Using Nix
   nix build

   # Or using Go directly
   go build -o inframan ./cmd/inframan
   ```

6. **Run the example** (optional, requires AWS credentials):
   ```bash
   cd example
   nix run .#account1 -- infra
   ```

## Making Changes

### Branching Strategy

1. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

   Use prefixes:
   - `feature/` - New features
   - `fix/` - Bug fixes
   - `docs/` - Documentation changes
   - `refactor/` - Code refactoring
   - `test/` - Test additions or modifications

2. **Keep your branch up to date**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

### Development Workflow

1. **Make your changes** in small, logical commits
2. **Test your changes** thoroughly
3. **Update documentation** if needed
4. **Run tests** (if available)
5. **Build the project** to ensure it compiles:
   ```bash
   nix build
   ```

### Commit Messages

Write clear, descriptive commit messages following this format:

```
<type>: <short summary>

<optional detailed description>

<optional footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Example:**
```
feat: add support for multiple cloud providers

- Add Azure provider support
- Refactor provider interface
- Update documentation

Closes #123
```

## Submitting Changes

### Before Submitting

1. **Ensure your code builds**:
   ```bash
   nix build
   ```

2. **Run tests** (if available):
   ```bash
   go test ./...
   ```

3. **Check code formatting**:
   ```bash
   go fmt ./...
   ```

4. **Update documentation** if you've changed:
   - Command-line interface
   - Configuration options
   - API or library functions

5. **Update the example** if relevant

### Creating a Pull Request

1. **Push your branch** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open a Pull Request** on GitHub:
   - Use a clear, descriptive title
   - Reference any related issues (e.g., "Fixes #123")
   - Describe what changes you made and why
   - Include any breaking changes
   - Add screenshots/examples if applicable

3. **PR Description Template**:
   ```markdown
   ## Description
   Brief description of changes

   ## Motivation
   Why are these changes needed?

   ## Changes Made
   - Change 1
   - Change 2

   ## Testing
   How were these changes tested?

   ## Related Issues
   Fixes #123
   ```

4. **Respond to feedback** - Maintainers may request changes

### Review Process

- Maintainers will review your PR
- Address any requested changes
- Once approved, a maintainer will merge your PR
- Your contribution will be included in the next release

## Coding Standards

### Go Code Style

- Follow standard Go conventions and idioms
- Use `go fmt` for formatting
- Use meaningful variable and function names
- Add comments for exported functions and types
- Keep functions focused and concise

**Example:**
```go
// NewTerraformExecutor creates a new Terraform executor instance
// with the configured working directory from PROJECT_NAME.
func NewTerraformExecutor() (*TerraformExecutor, error) {
    projectName := getProjectName()
    workDir := filepath.Join(".inframan", projectName, "terraform")

    return &TerraformExecutor{
        workDir: workDir,
    }, nil
}
```

### Nix Code Style

- Use consistent indentation (2 spaces)
- Add comments for complex expressions
- Follow Nix community best practices
- Use meaningful attribute names

### Project Structure

```
inframan/
├── cmd/
│   └── inframan/          # Main entry point
├── internal/
│   ├── cli/               # CLI command definitions
│   ├── commands/          # Command implementations
│   └── orchestrator/      # Core orchestration logic
├── example/               # Example configurations
├── flake.nix              # Nix flake definition
├── go.mod                 # Go module definition
└── README.md              # Project documentation
```

## Testing

### Running Tests

```bash
# Run all tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Run tests for a specific package
go test ./internal/orchestrator
```

### Writing Tests

- Add tests for new functionality
- Use table-driven tests where appropriate
- Mock external dependencies (Terraform, Colmena)
- Test error cases and edge conditions

**Example:**
```go
func TestNewTerraformExecutor(t *testing.T) {
    tests := []struct {
        name        string
        projectName string
        wantWorkDir string
    }{
        {
            name:        "default project",
            projectName: "default",
            wantWorkDir: ".inframan/default/terraform",
        },
        {
            name:        "custom project",
            projectName: "prod",
            wantWorkDir: ".inframan/prod/terraform",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test implementation
        })
    }
}
```

### Integration Testing

When testing with real infrastructure:

1. Use the `example/` directory as a reference
2. Test with minimal resources to reduce costs
3. Clean up resources after testing
4. Document any manual testing steps in your PR

## Documentation

### What to Document

- **Code comments**: For exported functions, types, and complex logic
- **README.md**: Update if you change core functionality or usage
- **Example files**: Update if you change configuration format
- **CONTRIBUTING.md**: Update if you change development workflow

### Documentation Style

- Use clear, concise language
- Include code examples where helpful
- Keep documentation up to date with code changes
- Use proper Markdown formatting

## Project-Specific Guidelines

### Working with Terranix

- Terranix configurations are in Nix format
- They compile to Terraform JSON
- Test changes with the example configurations
- Ensure backward compatibility when possible

### Working with Colmena

- Colmena uses NixOS modules
- The tool generates ephemeral `hive.nix` files
- Test deployment configurations carefully
- Consider multi-machine scenarios

### Working with the `.inframan/` Directory

- This directory is organized by project name
- Each project has separate `terraform/` and `colmena/` subdirectories
- Never commit this directory (it's in `.gitignore`)
- Ensure your changes support multiple projects

### Environment Variables

The tool uses these environment variables:

- `INFRA_CONFIG_JSON` - Path to Terranix-generated JSON
- `NIXOS_MODULE_PATH` - Path to NixOS configuration
- `PROJECT_NAME` - Project name for organizing files (default: "default")

When adding new environment variables:
1. Document them in the README
2. Add validation in the code
3. Provide sensible defaults where possible

## Getting Help

- **Questions**: Open a [GitHub Discussion](https://github.com/iivel-inc/inframan/discussions)
- **Bugs**: Open a [GitHub Issue](https://github.com/iivel-inc/inframan/issues)
- **Security**: Email security concerns to the maintainers (see README)

## License

By contributing to Inframan, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in:
- The project's contributor list
- Release notes for significant contributions
- The README (for major features)

Thank you for contributing to Inframan! 🚀

