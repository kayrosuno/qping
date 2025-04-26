/*
Copyright © 2023-2024 Alejandro Garcia (iacobus75@gmail.com)
*/
package main

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/tls"
	"crypto/x509"
	"encoding/pem"
	"math/big"
)

const sPortDefault = "25450"   //Puerto por defecto de escucha
const iPortDefault int = 25450 //Puerto por defecto de escucha

// const message = "Mensaje de prueba" //Mensaje de prueba por defecto
// var wg sync.WaitGroup               //grupo de sincronización de threads
var Program = "qping"   //Nombre del programa
var Version = "0.3.0"   //Version actual
const maxMessage = 2024 //Longitud en bytes maximo del mensaje

// Struct for RTT QUIC
type RTTQUIC struct {
	Id               int64  // id del mensaje.
	Time_client      int64  // local time at client
	Time_server      int64  // local time at server    `json:"Time_server,omitempty"`
	LenPayload       int    // len payload data
	LenPayloadReaded int    // len data readed on server side for payload (for MTU discovery?) `json:"LenPayloadReaded,omitempty"`
	Data             []byte // data of payload
}

// Setup a bare-bones TLS config for the server
func GenerateTLSConfig() *tls.Config {
	key, err := rsa.GenerateKey(rand.Reader, 1024)
	if err != nil {
		panic(err)
	}
	template := x509.Certificate{SerialNumber: big.NewInt(1)}
	certDER, err := x509.CreateCertificate(rand.Reader, &template, &template, &key.PublicKey, key)
	if err != nil {
		panic(err)
	}
	keyPEM := pem.EncodeToMemory(&pem.Block{Type: "RSA PRIVATE KEY", Bytes: x509.MarshalPKCS1PrivateKey(key)})
	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: certDER})

	tlsCert, err := tls.X509KeyPair(certPEM, keyPEM)
	if err != nil {
		panic(err)
	}
	return &tls.Config{
		Certificates: []tls.Certificate{tlsCert},
		NextProtos:   []string{"kayros.uno"},
		//NameToCertificate: ,
	}
}
