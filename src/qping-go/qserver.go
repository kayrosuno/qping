/*
Copyright © 2023 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
*/


// Package qgoserver implements a server for echoing data and rtt measure using QUIC protocols
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"os"
	"strconv"
	"time"

	"io"

	"github.com/quic-go/quic-go"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

// Start a server that echos all data for each stream opened by the client
func QPingServer(args []string) error {

	var port = sPortDefault
	var addr = "localhost:"
	//var rtt RTTQUIC

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
	log.Info().Str(Program, Version).Msg("qping server mode")

	//Check port
	if len(args) > 0 {

		_, err := strconv.Atoi(args[0])
		if err != nil {
			log.Error().Msg("incorrect argument port " + err.Error())
			port = sPortDefault
		}
		addr += args[0]
		port = args[0]
	} else {
		addr += sPortDefault
	}
	log.Info().Msg(fmt.Sprintf("Starting ping QUIC server on port: %s", port))

	//Crea el listener
	// listener, err := quic.ListenAddr(addr, GenerateTLSConfig(), nil)
	// if err != nil {
	// 	log.Error().Msg(fmt.Sprintf("Error %s", err.Error()))
	// 	return err
	// }

	var iPort, err = strconv.Atoi(port)
	if err != nil {
		log.Error().Msg("incorrect argument port " + err.Error())
		iPort = iPortDefault
	}

	udpConn, err := net.ListenUDP("udp4", &net.UDPAddr{Port: iPort})
	if err != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", err.Error()))
		return err
	}

	tr := quic.Transport{
		Conn: udpConn,
	}

	quicConf := quic.Config{}

	listener, err := tr.Listen(GenerateTLSConfig(), &quicConf)
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

		go newPingConnection(conn) //Nueva conexión de cliente
	}
}

// Nueva conexión aceptada
func newPingConnection(conn quic.Connection) {

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
	log.Info().Msg(fmt.Sprintf("Nueva conexión <-- %s", conn.RemoteAddr().String()))

	stream, err := conn.AcceptStream(context.Background())
	if err != nil {
		log.Error().Msg(fmt.Sprintf("Error accepting new stream: %s", err.Error()))
		return
		//panic(err)
	}

	//Cerrar diferido
	defer stream.Close()

	// Echo local for data send by client
	for {
		//
		//Leer los datos
		//----------------------------
		//
		buf := make([]byte, maxMessage)
		bytesReaded, err := io.ReadAtLeast(stream, buf, 20)
		if err != nil {
			if err != io.EOF {
				//Log error
				log.Error().Msg(fmt.Sprintf("Client %s '%s'", conn.RemoteAddr().String(), err.Error()))
				break
			}
		}

		//Unmarshalling JSON
		var rtt RTTQUIC

		if err := json.Unmarshal(buf[:bytesReaded], &rtt); err != nil { //El unmarshal se lee de un slice con los datos leidos, no mas para evitar datos erroneos
			log.Error().Msg(fmt.Sprintf("Error unmarshalling json data: %s", err.Error()))
			break
		}

		rtt.Time_server = time.Now().UnixMicro()
		rtt.LenPayloadReaded = len(rtt.Data)

		//log.Info().Msg(fmt.Sprintf("<<<: %s Got '%s'", conn.RemoteAddr().String(), string(buf)))

		//
		//Escribir respuesta al cliente
		//----------------------------
		//

		//marshall json
		data, err := json.Marshal(rtt)
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Json marshall failed '%s'", err.Error()))
			continue
		}
		//
		//Enviar data json
		//
		_, err = stream.Write(data)
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
			continue
		}

		//Int64("t_marshall", time_marshall).Int64("t_send", time_send).
		//log.Info().Msg(fmt.Sprintf("-> '%s' mesg: '%s'", conn.RemoteAddr().String(), data))

	}

	//Log error
	log.Info().Msg(fmt.Sprintf("Close connection client %s ", conn.RemoteAddr().String()))

}
