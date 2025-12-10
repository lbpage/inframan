package orchestrator

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

// TerranixExecutor handles Terranix command execution for generating Terraform JSON from Nix
type TerranixExecutor struct {
	workDir string
}

// NewTerranixExecutor creates a new Terranix executor
func NewTerranixExecutor() (*TerranixExecutor, error) {
	workDir, err := GetTerraformDir()
	if err != nil {
		return nil, fmt.Errorf("failed to get terraform directory: %w", err)
	}

	// Ensure the directory exists
	if err := EnsureDir(workDir); err != nil {
		return nil, err
	}

	return &TerranixExecutor{workDir: workDir}, nil
}

// Build runs terranix to generate config.tf.json from a Nix file
// This executes: nix-build --no-out-link -E 'with import <nixpkgs> {}; terranix.lib.terranixConfiguration { modules = [ <nixFile> ]; }'
// Or more commonly: terranix <nixFile> > config.tf.json
func (t *TerranixExecutor) Build(nixFilePath string) (string, error) {
	// Get absolute path to the nix file
	absNixPath, err := filepath.Abs(nixFilePath)
	if err != nil {
		return "", fmt.Errorf("failed to get absolute path: %w", err)
	}

	// Verify the nix file exists
	if _, err := os.Stat(absNixPath); os.IsNotExist(err) {
		return "", fmt.Errorf("nix file does not exist: %s", absNixPath)
	}

	// Run terranix to generate JSON
	cmd := exec.Command("terranix", absNixPath)
	cmd.Env = os.Environ()

	output, err := cmd.Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return "", fmt.Errorf("terranix build failed: %w\n%s", err, string(exitErr.Stderr))
		}
		return "", fmt.Errorf("terranix build failed: %w", err)
	}

	// Write the output to config.tf.json in terraform directory
	outputPath := filepath.Join(t.workDir, ConfigFileName)
	if err := os.WriteFile(outputPath, output, 0644); err != nil {
		return "", fmt.Errorf("failed to write terraform config: %w", err)
	}

	return outputPath, nil
}

// BuildFromConfig copies an existing Terranix-generated JSON config to the terraform directory
// This is used when the config is pre-generated (e.g., via flake.nix)
func (t *TerranixExecutor) BuildFromConfig(configPath string) (string, error) {
	// Read the source config file
	data, err := os.ReadFile(configPath)
	if err != nil {
		return "", fmt.Errorf("failed to read config file: %w", err)
	}

	// Write to terraform dir as config.tf.json
	outputPath := filepath.Join(t.workDir, ConfigFileName)
	if err := os.WriteFile(outputPath, data, 0644); err != nil {
		return "", fmt.Errorf("failed to write config file: %w", err)
	}

	return outputPath, nil
}

// GetWorkDir returns the workdir path
func (t *TerranixExecutor) GetWorkDir() string {
	return t.workDir
}

// GetConfigPath returns the path to the generated config.tf.json
func (t *TerranixExecutor) GetConfigPath() string {
	return filepath.Join(t.workDir, ConfigFileName)
}
