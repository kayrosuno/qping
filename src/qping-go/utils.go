/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>
*/
package share

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/tls"
	"crypto/x509"
	"encoding/pem"
	"math/big"
)

// Struct for RTT QUIC
type RTTQUIC struct {
	Magic         uint16 // magic to identify this packet
	Id            uint32 // id del mensaje
	Time_client   uint64 // local time at client
	Time_server   uint64 // local time at server
	LenData       uint16 // len payload data
	Data          []byte // data of payload
	LenDataReaded uint16 // len data readed on server side (for MTU discovery?)
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
