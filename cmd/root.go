package cmd

import (
	"fmt"
	"log"
	"os"

	"github.com/footgunz/proxbox/internal/proxy"

	"github.com/spf13/cobra"
)

var rootCmdFlags struct {
	httpPort int
	socksPort int
	quiet    bool
	verbose  bool
}

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "proxbox",
	Short: "Start a proxy server",
	Long:  `an http and socks5 proxy server`,
	Run: func(cmd *cobra.Command, args []string) {
		// Create error channel to handle server errors
		errChan := make(chan error, 2)

		// Start HTTP proxy in a goroutine
		go func() {
			if err := proxy.StartHTTPProxy(rootCmdFlags.httpPort, rootCmdFlags.quiet, rootCmdFlags.verbose); err != nil {
				errChan <- fmt.Errorf("HTTP proxy error: %v", err)
			}
		}()

		// Start SOCKS proxy in a goroutine
		go func() {
			if err := proxy.StartSocksProxy(rootCmdFlags.socksPort, rootCmdFlags.quiet, rootCmdFlags.verbose); err != nil {
				errChan <- fmt.Errorf("SOCKS proxy error: %v", err)
			}
		}()

		// Wait for any errors
		if err := <-errChan; err != nil {
			log.Fatalf("Proxy server failed: %v", err)
		}
	},
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.

	// rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.proxbox.yaml)")

	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	rootCmd.PersistentFlags().IntVarP(&rootCmdFlags.httpPort, "http-port", "p", 8889, "Port to listen on")
	rootCmd.PersistentFlags().IntVarP(&rootCmdFlags.socksPort, "socks-port", "s", 8890, "Port to listen on")
	rootCmd.PersistentFlags().BoolVarP(&rootCmdFlags.quiet, "quiet", "q", false, "Quiet mode - suppress all normal output")
	rootCmd.PersistentFlags().BoolVarP(&rootCmdFlags.verbose, "verbose", "v", false, "Verbose mode - show detailed logs")
}
