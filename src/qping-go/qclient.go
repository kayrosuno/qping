/*
Copyright © 2023-2024 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
*/
package main

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"net"
	"os"
	"time"

	"github.com/quic-go/quic-go"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

// We start a server echoing data on the first stream the client opens,
// then connect with a client, send the message, and wait for its receipt.
const message = "qclient rtt message"

// Main echo client
// llamada -> qgo ipaddress:port
func QClient(args []string) {

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})
	log.Info().Str(Program, Version).Msg("qping client mode")

	// Check UPD addreess for QUIC
	udpAdr, err := net.ResolveUDPAddr("udp", args[0])
	log.Info().Str("arg0", args[0]).Msg("<< arg[0]")
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

	//Cerrar diferido
	defer stream.Close()

	//UUID
	//var uuid = uuid.New().String()
	//Bucle de envío continuo del cliente
	for i := 0; true; i++ {

		//Crear el mensaje
		var rttMensaje RTTQUIC
		rttMensaje.Id = int64(i)
		rttMensaje.Data = []byte(message)
		rttMensaje.LenPayload = len(message)

		var time_init = time.Now().UnixMicro()
		rttMensaje.Time_client = time_init
		rttMensaje.Time_server = 0
		rttMensaje.LenPayloadReaded = 0

		data, err := json.Marshal(rttMensaje)
		//var time_marshall = time.Now().UnixMicro() - time_init

		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Json marshall failed '%s'", err.Error()))
			return
		}
		//
		//Enviar data json
		//----------------------------
		//
		//var time_send = time.Now().UnixMicro() - time_init
		_, err = stream.Write(data)
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
			return
		}
		//var time_sended = time.Now().UnixMicro() - time_init
		//log.Info().Int64("t_marshall", time_marshall).Int64("t_send", time_send).Msg(fmt.Sprintf("-> '%s' mesg: '%s'", args[0], data))

		//
		//Leer echo desde el server
		//
		// TODO
		err = stream.SetReadDeadline(time.Now().Add(time.Second)) // 1seg
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
			return
		}

		//var bytes_leidos = 0
		buf := make([]byte, maxMessage) //Buffer
		bytesReaded, err := stream.Read(buf)
		if err != nil {
			//Log error
			log.Error().Msg(fmt.Sprintf("Error '%s'", err.Error()))
			return
		}

		//Time RTT
		var time_rtt = time.Now().UnixMicro() - time_init

		//Unmarshall answer from server
		var rttServer RTTQUIC

		if err := json.Unmarshal(buf[:bytesReaded], &rttServer); err != nil { //El unmarshal se lee de un slice con los datos leidos, no mas para evitar datos erroneos
			log.Error().Msg(fmt.Sprintf("Error unmarshalling json data: %s", err.Error()))
			continue
		}

		//log.Info().Msg(fmt.Sprintf("<-  mesg: '%s'", datos_leidos))
		log.Info().
			//Int64("t_marshall", time_marshall).

			Int64("id", rttServer.Id).
			Int64("rtt usec", time_rtt).
			//Int64("t_server", rttServer.Time_server-rttMensaje.Time_client).
			//cInt64("t_send", time_send).
			//Msg(fmt.Sprintf(" RT='%d'usec", time_rtt))

			Msg("") //fmt.Sprintf("<- '%s' mesg: '%s'", args[0], data))

		//Esperar 1 seg TODO: eliminar
		time.Sleep(1 * time.Second)

	}

}
