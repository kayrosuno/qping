// Package qgoserver implements a server for echoing data and rtt measure using QUIC protocols
package server

import (
	"context"
	"fmt"
	"os"
	"strconv"

	"io"

	"github.com/quic-go/quic-go"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"kayros.uno/qgo/share"
)

const portDefault = "25450" //Puerto por defecto de escucha
// const message = "Mensaje de prueba" //Mensaje de prueba por defecto
// var wg sync.WaitGroup               //grupo de sincronización de threads
var Program = "qgoserver" //Nombre del programa
var Version = "0.1"       //Version actual
const maxMessage = 1024   //Longitud en bytes maximo del mensaje

// Start a server that echos all data for each stream opened by the client
func EchoServer(args []string) error {

	var port = portDefault
	var addr = "localhost:"
	var rtt share.RTTQUIC

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
	log.Info().Str(Program, Version).Msg("qgo server mode")

	//Check port
	if len(args) > 0 {

		_, err := strconv.Atoi(args[0])
		if err != nil {
			log.Error().Msg("incorrect argument port " + err.Error())
			port = portDefault
		}
		addr += args[0]
		port = args[0]
	} else {
		addr += portDefault
	}
	log.Info().Msg(fmt.Sprintf("Iniciando servidor QUIC echo en puerto: %s", port))

	//Crea el listener
	listener, err := quic.ListenAddr(addr, share.GenerateTLSConfig(), nil)
	if err != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", err.Error()))
		return err
	}

	for {
		//Escucha en el puerto indicado, y bloquea a la espera
		conn, err := listener.Accept(context.Background()) //Escuchar por nuevas conexiones
		if err != nil {
			log.Error().Msg(fmt.Sprintf("Error with new connection: %s", err.Error()))
			return err
		}

		go newEchoConnection(conn) //Nueva conexión de cliente
	}

	//return err
}

// Start a server that echos and return rtt time all data for each stream opened by the client
func RTTServer(args []string) error {

	//TODO: copiado de EchoServer, pero no probado no operativo aun

	var port = portDefault
	var addr = "localhost:"

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
	log.Info().Str(Program, Version).Msg("qgo server mode")

	//Check port
	if len(args) > 0 {

		_, err := strconv.Atoi(args[0])
		if err != nil {
			log.Error().Msg("incorrect argument port " + err.Error())
			port = portDefault
		}
		addr += args[0]
		port = args[0]
	} else {
		addr += portDefault
	}
	log.Info().Msg(fmt.Sprintf("Iniciando servidor QUIC echo en puerto: %s", port))

	//Crea el listener
	listener, err := quic.ListenAddr(addr, share.GenerateTLSConfig(), nil)
	if err != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", err.Error()))
		return err
	}

	for {
		//Escucha en el puerto indicado, y bloquea a la espera
		conn, err := listener.Accept(context.Background()) //Escuchar por nuevas conexiones
		if err != nil {
			log.Error().Msg(fmt.Sprintf("Error with new connection: %s", err.Error()))
			return err
		}

		go newEchoConnection(conn) //Nueva conexión de cliente
	}

}

// Nueva conexión aceptada de tipo echo server
func newEchoConnection(conn quic.Connection) {

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
	log.Info().Msg(fmt.Sprintf("EchoServer: Iniciando nueva conexión: %s", conn.RemoteAddr().Network()))

	stream, err := conn.AcceptStream(context.Background())
	if err != nil {
		log.Error().Msg(fmt.Sprintf("Error accepting new stream: %s", err.Error()))
		return
		//panic(err)
	}

	// Echo local for data send by client
	for {

		//Leer los datos
		//TODO: responder a todos los clientes
		buf := make([]byte, maxMessage)
		_, err = io.ReadAtLeast(stream, buf, 10)
		if err != nil {
			if err != io.EOF {
				log.Error().Msg(err.Error())
			}
		}
		log.Info().Msg(fmt.Sprintf("<<<: %s Got '%s'", conn.RemoteAddr().String(), string(buf)))
	}

}

// Nueva conexión aceptada de tipo rtt server
func newRTTConnection(conn quic.Connection) {

	stream, err := conn.AcceptStream(context.Background())
	if err != nil {
		panic(err)
	}
	// Echo through the loggingWriter
	for {

		//TODO: mensajeria con JSON y calculo de RTT

		//Escribir
		//TODO: responder a todos los clientes
		buf := make([]byte, maxMessage)
		_, err = io.ReadFull(stream, buf)
		if err != nil {
			panic(err) //TODO: quitar
		}
		log.Info().Str("<<<: Got '%s'\n", string(buf))
	}

}
