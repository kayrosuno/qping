/*
Copyright © 2023 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
*/
package main

import (
	"net"
	"os"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/spf13/cobra"
)

// Función main de entrada
func main() {
	Execute() //Ejecución de comandos con cobra

}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

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

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "qping <ipaddres:port>",
	Short: "Start qping in server mode to listen for clients request, the port must by greater than 1024",
	Long: `qping is a test program written in go to verify the functionality of the QUIC Protocol:
qping act as ac lient or as ping server listening ping from querys from the clients answering
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
		QClient(args)
	},
}

// versionCmd represents the version command
var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Show applications versions",
	Long:  `Show the applications versions for the client and server modes`,
	Run: func(cmd *cobra.Command, args []string) {
		//fmt.Println("version called")

		log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
		log.Info().Str(Program, Version).Msg("")

	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
	rootCmd.AddCommand(serverCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// versionCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// versionCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.

	// rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.qgoserver.yaml)")

	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	rootCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
