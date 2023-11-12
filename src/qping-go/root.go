/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package main

import (
	"net"
	"os"

	"github.com/spf13/cobra"
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "qping <ipaddres:port>",
	Short: "Start qping in server mode to listen for clients request, the port must by greater than 1024",
	Long: `qping is a test program written in go to verify the functionality of the QUIC Protocol:
qgoserver act a ping server listening ping from querys from the clients answerring
with a time mark to measure on the client the RTT `,
	Args: func(cmd *cobra.Command, args []string) error {

		// Optionally run one of the validators provided by cobra
		if err := cobra.MinimumNArgs(1)(cmd, args); err != nil {
			return err
		}

		// Chech UPD addreess for QUIC
		_, err := net.ResolveUDPAddr("udp", args[0])
		if err != nil {
			return err
		}

		// if(udpAddr.IP)
		// //return net.ListenUDP("udp", udpAddr)
		return nil

		//return fmt.Errorf("invalid color specified: %s", args[0])
	},
	// Uncomment the following line if your bare application
	// has an action associated with it:
	Run: func(cmd *cobra.Command, args []string) {
		RTTClient(args)
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

	// rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.qgoserver.yaml)")

	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	rootCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
