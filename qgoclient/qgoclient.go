package main

import (
    "context"
    "crypto/rand"
    "crypto/rsa"
    "crypto/tls"
    "crypto/x509"
    "encoding/pem"
    "fmt"
    "io"
 //   "log"
    "math/big"
    "sync"

    "github.com/quic-go/quic-go"
)

const addr = "localhost:25450"

const message = "Hola, cliente enviando mensaje QUIC"

// We start a server echoing data on the first stream the client opens,
// then connect with a client, send the message, and wait for its receipt.

var wg sync.WaitGroup

var program = "qgoclient"
var version = "0.1"

// A wrapper for io.Writer that also logs the message.
type loggingWriter struct{ io.Writer }

func (w loggingWriter) Write(b []byte) (int, error) {
    fmt.Printf("Server: Got '%s'\n", string(b))
    return w.Writer.Write(b)
}

func main()  {

    fmt.Println(program, version)

    tlsConf := &tls.Config{
        InsecureSkipVerify: true,
        NextProtos:         []string{"kayros"},
    }
    conn, err := quic.DialAddr(context.Background(), addr, tlsConf, nil)
    //conn, err := quic.DialAddr(addr, tlsConf, nil)
    if err != nil {
        //return err
        //Log error
            fmt.Printf("Error '%s'\n", err)
    }

    stream, err := conn.OpenStreamSync(context.Background())
    if err != nil {
               //Log error
            fmt.Printf("Error '%s'\n", err)
    }

    fmt.Printf("Client: Sending '%s'\n", message)
    _, err = stream.Write([]byte(message))
    if err != nil {
               //Log error
            fmt.Printf("Error '%s'\n", err)
    }

    buf := make([]byte, len(message))
    _, err = io.ReadFull(stream, buf)
    if err != nil {
                //Log error
            fmt.Printf("Error '%s'\n", err)
    }
    fmt.Printf("Client: Got '%s'\n", buf)


}

// Setup a bare-bones TLS config for the server
func generateTLSConfig() *tls.Config {
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
        NextProtos:   []string{"kayros"},
    }
}

