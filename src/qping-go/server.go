/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package main

import (
	"github.com/spf13/cobra"
)

// serverCmd represents the server command
var serverCmd = &cobra.Command{
	Use:   "server <port>",
	Short: "Start qping in server mode to listen for QUIC connections",
	Long: `Start qping in server mode to listen for QUIC connections using 
	the default port to listen for clients`,
	Args: func(cmd *cobra.Command, args []string) error {

		// // Optionally run one of the validators provided by cobra
		// if err := cobra.MinimumNArgs(1)(cmd, args); err != nil {
		// 	return err
		// }

		// // Chech port for QUIC
		// _, err := strconv.Atoi(args[0])
		// if err != nil {
		// 	return err
		// }

		return nil

	},
	Run: func(cmd *cobra.Command, args []string) {
		QPingServer(args)
	},
}

func init() {
	rootCmd.AddCommand(serverCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// serverCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// serverCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
