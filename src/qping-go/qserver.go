/*
Copyright © 2023 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
*/

// Package qgoserver implements a server for echoing data and rtt measure using QUIC protocols
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"os"
	"strconv"
	"sync"
	"time"

	"github.com/quic-go/quic-go"
	"github.com/redis/go-redis/v9" //REDIS
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

// Start a server that echos all data for each stream opened by the client
func QPingServer(args []string) error {

	var port = sPortDefault
	var addr = "localhost:"
	//var rtt RTTQUIC
	var wg sync.WaitGroup

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})

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

	//TODO, check IPV4 or IPv6
	//var udpConn *net.UDPConn
	//if net.IP.To4(net.IP) != nil {

	udpConn, err := net.ListenUDP("udp4", &net.UDPAddr{Port: iPort})
	if err != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", err.Error()))
		return err
	}

	udpConn6, err6 := net.ListenUDP("udp6", &net.UDPAddr{Port: iPort})
	if err6 != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", err6.Error()))
		return err6
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
	log.Info().Msg(fmt.Sprintf("Starting ping QUIC server IPv4 on port: %s", listener.Addr().String()))

	//IPv6
	tr6 := quic.Transport{
		Conn: udpConn6,
	}

	quicConf6 := quic.Config{}

	listener6, err6 := tr6.Listen(GenerateTLSConfig(), &quicConf6)
	if err6 != nil {
		log.Error().Msg(fmt.Sprintf("Error %s", err6.Error()))
		return err6
	}
	log.Info().Msg(fmt.Sprintf("Starting ping QUIC server IPv6 on port: %s", listener6.Addr().String()))

	wg.Add(2)

	//Listen IPv4
	go listenIPv4(listener, &wg)

	//Listen IPv6
	go listenIPv6(listener6, &wg)

	wg.Wait()

	return err //ipv4
}

// Nueva conexión aceptada
func listenIPv4(listener *quic.Listener, wg *sync.WaitGroup) {
	for { //TODO check SIGTERM
		//Escucha en el puerto indicado, y bloquea a la espera
		conn, err := listener.Accept(context.Background()) //Escuchar por nuevas conexiones
		if err != nil {
			log.Error().Msg(fmt.Sprintf("Error with new connection: %s", err.Error()))
			//return err
		}

		go newPingConnection(conn) //Nueva conexión de cliente
	}

}

// Nueva conexión aceptada
func listenIPv6(listener6 *quic.Listener, wg *sync.WaitGroup) {
	for {
		//Escucha en el puerto indicado, y bloquea a la espera
		conn6, err6 := listener6.Accept(context.Background()) //Escuchar por nuevas conexiones
		if err6 != nil {
			log.Error().Msg(fmt.Sprintf("Error with new connection: %s", err6.Error()))
			//return err6
		}

		go newPingConnection(conn6) //Nueva conexión de cliente
	}
}

// Nueva conexión aceptada
func newPingConnection(conn quic.Connection) {

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339})

	log.Info().Msg(fmt.Sprintf("Nueva conexión <-- %s", conn.RemoteAddr().String()))

	//Connecty to redis server
	clientRedis := redis.NewClient(&redis.Options{
		Addr:     "127.0.0.1:6379",
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	ctx := context.Background()

	err := clientRedis.Set(ctx, "Cliente XX", "ping xx ms", 0).Err()
	if err != nil {
		//panic(err)
		log.Error().Msg(fmt.Sprintf("Error redis server: %s", err.Error()))
	}

	val, err := clientRedis.Get(ctx, "Cliente XX").Result()
	if err != nil {
		//panic(err)
		log.Error().Msg(fmt.Sprintf("Error redis server: %s", err.Error()))
	} else {
		//fmt.Println("foo", val)
		log.Info().Msg(fmt.Sprintf("Valor de prueba cliente XX: %s", val))
	}

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
