package orchestrator

import (
	"fmt"
	"os"
	"path/filepath"
)

const (
	// InframanDir is the root directory for all inframan-generated files
	InframanDir = ".inframan"

	// TerraformSubdir is the subdirectory for terraform state and config
	TerraformSubdir = "terraform"

	// ColmenaSubdir is the subdirectory for colmena hive files
	ColmenaSubdir = "colmena"

	// ConfigFileName is the name of the terraform config file
	ConfigFileName = "config.tf.json"

	// HiveFileName is the name of the colmena hive file
	HiveFileName = "hive.nix"
)

// GetInframanDir returns the absolute path to the .inframan directory
func GetInframanDir() (string, error) {
	cwd, err := os.Getwd()
	if err != nil {
		return "", fmt.Errorf("failed to get working directory: %w", err)
	}
	return filepath.Join(cwd, InframanDir), nil
}

// GetTerraformDir returns the absolute path to the terraform subdirectory
func GetTerraformDir() (string, error) {
	inframanDir, err := GetInframanDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(inframanDir, TerraformSubdir), nil
}

// GetColmenaDir returns the absolute path to the colmena subdirectory
func GetColmenaDir() (string, error) {
	inframanDir, err := GetInframanDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(inframanDir, ColmenaSubdir), nil
}

// EnsureDir creates a directory if it doesn't exist
func EnsureDir(path string) error {
	if err := os.MkdirAll(path, 0755); err != nil {
		return fmt.Errorf("failed to create directory %s: %w", path, err)
	}
	return nil
}

// InitInframanDirs creates the .inframan directory structure
func InitInframanDirs() error {
	terraformDir, err := GetTerraformDir()
	if err != nil {
		return err
	}
	if err := EnsureDir(terraformDir); err != nil {
		return err
	}

	colmenaDir, err := GetColmenaDir()
	if err != nil {
		return err
	}
	if err := EnsureDir(colmenaDir); err != nil {
		return err
	}

	return nil
}

