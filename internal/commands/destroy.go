package commands

import (
	"fmt"

	"github.com/iivel-inc/inframan/internal/orchestrator"
	"github.com/spf13/cobra"
)

// NewDestroyCommand creates the destroy command
func NewDestroyCommand() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "destroy",
		Short: "Destroy infrastructure using Terraform",
		Long: `Destroy tears down infrastructure provisioned by inframan:
1. Runs terraform destroy in the project's terraform directory
2. Removes all resources tracked in the terraform state
3. Passes through AWS credentials from environment

This is the reverse of 'inframan infra' and will destroy all resources
that were created during infrastructure provisioning.`,
		RunE: func(cmd *cobra.Command, args []string) error {
			// Create terraform executor
			terraformExec, err := orchestrator.NewTerraformExecutor()
			if err != nil {
				return fmt.Errorf("failed to create terraform executor: %w", err)
			}

			// Run terraform destroy
			fmt.Println("Destroying infrastructure...")
			if err := terraformExec.Destroy(); err != nil {
				return fmt.Errorf("terraform destroy failed: %w", err)
			}

			fmt.Println("Infrastructure destroyed successfully!")
			return nil
		},
	}

	return cmd
}

