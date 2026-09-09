# Informe: Kubernetes con Minikube

**Estudiante:** Natalia Hernández  
**Arquitectura:** ARM64  
**Entorno:** Ubuntu 22.04 en Vagrant, Docker y Minikube

## Objetivo

Comprender el funcionamiento de Kubernetes mediante un clúster local de un nodo, despliegues, servicios, escalado, balanceo, observación, Ingress y actualizaciones progresivas.

## Adaptaciones actuales

Se instaló el binario ARM64 de Minikube y la versión estable actual de `kubectl`. Minikube usa el controlador Docker, compatible con Linux ARM64. La aplicación `hello-node` se construyó con `node:22-alpine` en lugar de Node 4.4, que es una versión obsoleta.

## Desarrollo

Se inició Minikube con dos CPU, 2600 MB de memoria y un disco de 8 GB. Se registraron las versiones, información del clúster, nodos, pods del sistema, eventos y configuración de `kubectl`.

`hello-minikube` se desplegó con `kicbase/echo-server:1.0` y un Service NodePort. Se comprobó la respuesta HTTP y se consultaron sus registros.

El Dashboard se habilitó como complemento y se probó mediante un proxy temporal en el puerto 8001 de `servidorUbuntu`.

La aplicación `hello-node` devuelve el nombre del pod y su versión. Se construyeron las imágenes v1 y v2 dentro de Minikube, se desplegó v1, se inspeccionaron sus pods, registros, variables y el archivo fuente desde el contenedor.

El Deployment se escaló de una a cuatro réplicas. Las peticiones sucesivas fueron atendidas por diferentes nombres de pod, lo que demostró el balanceo de carga del Service. Después se redujo a dos réplicas.

## Ingress Controller

Un Ingress Controller observa los recursos Ingress y configura un proxy de entrada para dirigir tráfico HTTP o HTTPS hacia distintos Services. Se habilitó Ingress NGINX y se creó el host `practica.local` con dos rutas:

- `/node` dirige a `hello-node`.
- `/echo` dirige a `hello-minikube`.

Las dos rutas se comprobaron usando la IP de Minikube y el encabezado HTTP `Host: practica.local`.

## Rolling update

Se escaló `hello-node` a cuatro réplicas y se cambió la imagen de v1 a v2. Kubernetes reemplazó gradualmente los pods según la estrategia RollingUpdate, manteniendo instancias disponibles. El historial del Deployment y las respuestas HTTP confirmaron la versión v2.

## GPU

El material adicional de GPU corresponde a NVIDIA CUDA. La prueba requiere una GPU NVIDIA, controladores NVIDIA en Linux y NVIDIA Container Toolkit. La VM ARM64 sobre un Mac Apple Silicon no dispone de ese dispositivo, por lo que el ejemplo se conservó como referencia y no se instaló software que pudiera alterar Docker sin ofrecer aceleración real.

## Limpieza

Se eliminaron los deployments, services e ingress creados. El proxy del Dashboard se detuvo y Minikube quedó apagado, conservando su perfil y las evidencias.

