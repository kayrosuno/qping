package client

import (
	"context"
	"crypto/tls"
	"fmt"
	"net"
	"os"
	"time"

	//	"crypto/tls"

	//   "log"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"

	"github.com/quic-go/quic-go"
)

// We start a server echoing data on the first stream the client opens,
// then connect with a client, send the message, and wait for its receipt.

// var wg sync.WaitGroup
var Program = "qgoclient" //Nombre del programa cliente
var Version = "0.1"       //Version actual cliente
//var addr = "localhost:25450"

const message = "QUIC echo test message from go client"

// Main echo client
// llamada -> qgo ipaddress:port
func EchoClient(args []string) {

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
	log.Info().Str(Program, Version).Msg("qgo client mode")

	// Chech UPD addreess for QUIC
	udpAdr, err := net.ResolveUDPAddr("udp", args[0])
	if err != nil {
		log.Panic().Msg(err.Error())
		panic(err.Error())
	}
	log.Info().Str("IP:", udpAdr.IP.String()).Str("Port", fmt.Sprint(udpAdr.Port)).Msg("Connecting to remote peer")

	//Check parameters
	tlsConf := &tls.Config{
		InsecureSkipVerify: true,
		NextProtos:         []string{"kayros.uno"},
	}

	//Conectar al servidor QUIC remoto
	conn, err := quic.DialAddr(context.Background(), args[0], tlsConf, nil)
	if err != nil {
		//Log error
		log.Error().Msg(fmt.Sprintf("'%s'\n", err.Error()))
		return
	}

	stream, err := conn.OpenStreamSync(context.Background())
	if err != nil {
		//Log error
		log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
		return
	}

	//Bucle de envío continuo
	for {
		log.Info().Msg(fmt.Sprintf("-> '%s' mesg: '%s'", args[0], message))

		//Enviar echo
		_, err = stream.Write([]byte(message))
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
			return
		}

		//Leer echo desde el server
		// TODO

		//Esperar 1 seg TODO: eliminar
		time.Sleep(1 * time.Second)

	}

	// buf := make([]byte, len(message))
	// _, err = io.ReadFull(stream, buf)
	// if err != nil {
	// 	//Log error
	// 	log.Error().Msg(fmt.Sprintf("Error '%s'\n", err.Error()))
	// 	return
	// }

	//log.Error().Msg(fmt.Sprintf("Error '%s'\n", string(buf)))

}
