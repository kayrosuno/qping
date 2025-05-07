#QPing go version
Version de QPing para go

## Build

En el directorio de qping compilar para go.


#### Compilar
El modulo de go es: kayros.uno/qping

`go build kayros.uno/qping`


####Crear imagen de docker

`docker image build -t italtelspain/qping:0.1.0   -t italtelspain/qping:latest  .
`

`docker image build -t kayrosuno/qping:0.2   -t kayrosuno/qping:latest  .
`

Se utiliza el fichero Dockerfile, que establece dos fases, una para compilar go con la imagen golang y otra para la distribución basada en la imagen de ubuntu

Hay diferentes ficheros Dockerfile con distintas arquitecturas



###Push al repositorio de docker.io

`docker image push italtelspain/qping:0.1.0`

`docker image push kayrosuno/qping:0.2`



###Ejecutar container y hacer port forward al 25450 en udp!!
`docker container run -it -p 25450:25450/udp  qping:1.0
`

#Test
Ejecutar qping en modo cliente:

`qping <ip_container>:25450`


Copyright © 2023-2025 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.




