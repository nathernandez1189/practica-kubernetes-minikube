# Práctica Kubernetes con Minikube

Proyecto independiente para completar la práctica de Kubernetes en `servidorUbuntu` ARM64 usando Minikube con el controlador Docker.

## Alcance

- Instalación ARM64 de Minikube y `kubectl`.
- Creación y revisión del clúster local.
- Deployment y Service NodePort de `hello-minikube`.
- Dashboard de Kubernetes mediante un proxy temporal.
- Construcción de la imagen `hello-node` dentro de Minikube.
- Inspección de pods, registros, variables y comandos internos.
- Escalado a cuatro réplicas y reducción a dos.
- Balanceo de carga entre pods.
- Ingress Controller con rutas `/node` y `/echo`.
- Rolling update de `hello-node:v1` a `hello-node:v2`.
- Limpieza de recursos y detención de Minikube.

## Compatibilidad ARM

El documento ofrece binarios separados para ARM64. Los scripts detectan la arquitectura e instalan las versiones actuales correspondientes. La aplicación Node usa `node:22-alpine`, que tiene soporte ARM64, en lugar de una imagen Node 4.4 obsoleta.

## Material sobre GPU

El ZIP de GPU se conserva en `referencias`. Su ejemplo necesita una GPU NVIDIA visible dentro de Linux y su controlador correspondiente. La máquina usada en esta práctica es una VM ARM64 de VirtualBox sobre Apple Silicon y no expone una GPU NVIDIA, por lo que instalar `nvidia-docker2` o ejecutar `--gpus all` no produciría una prueba válida.

## Ejecución

Dentro de `servidorUbuntu`:

```bash
cd /home/vagrant/proyectos/practica-kubernetes-minikube
./scripts/instalar-herramientas.sh
./scripts/ejecutar-practica.sh
```

Al terminar, Minikube queda detenido y conserva su perfil para futuras revisiones.

El informe listo para entregar está disponible en Word y PDF dentro de `docs/`. La guía de sustentación resume los conceptos, el recorrido de la demostración y las evidencias principales.

[Informe para sustentación en vivo en PDF](docs/Informe-Sustentacion-Kubernetes-Minikube.pdf) · [Word](docs/Informe-Sustentacion-Kubernetes-Minikube.docx)
