# Guía breve para la sustentación

## Qué se hizo

La práctica creó un clúster local de Kubernetes con Minikube dentro de una máquina virtual Ubuntu ARM64. Se instalaron Docker, Minikube y kubectl; luego se desplegaron dos aplicaciones, se publicaron con servicios, se probaron desde la red y se administró su ciclo de vida.

## Conceptos que conviene explicar

- **Pod:** unidad mínima que ejecuta uno o más contenedores.
- **Deployment:** mantiene la cantidad deseada de pods y permite actualizar la aplicación.
- **Service:** da una dirección estable para acceder a pods que pueden cambiar.
- **NodePort:** publica un servicio en un puerto del nodo.
- **Ingress:** dirige peticiones HTTP a distintos servicios según la ruta.
- **Escalado:** cambia la cantidad de réplicas de una aplicación.
- **Rolling update:** reemplaza los pods de forma gradual para actualizar sin detener el servicio.

## Recorrido de la demostración

1. Mostrar las versiones de Minikube y kubectl y el nodo en estado `Ready`.
2. Explicar el despliegue `hello-minikube` y su servicio NodePort.
3. Mostrar `hello-node`, construido como imagen local y ejecutado en Kubernetes.
4. Enseñar que cada respuesta identifica el pod que la atendió.
5. Escalar de una a cuatro réplicas y mostrar el reparto de peticiones.
6. Reducir a dos réplicas.
7. Explicar las rutas del Ingress: `/node` y `/echo`.
8. Mostrar la actualización gradual de `v1` a `v2`.
9. Enseñar la limpieza de recursos y el clúster detenido.

## Evidencias principales

- `01-versiones-cluster.txt`: versiones del clúster.
- `02-nodos.txt`: nodo ARM64 en estado correcto.
- `07-hello-minikube-http.txt`: respuesta del primer servicio.
- `09-dashboard-http.txt`: panel de Kubernetes accesible.
- `13-hello-node-port-forward.txt`: acceso mediante redirección de puerto.
- `20-balanceo-cuatro-pods.txt`: peticiones atendidas por cuatro pods.
- `22-ingress-rutas.txt`: enrutamiento a los dos servicios.
- `26-rolling-update-pods.txt`: reemplazo gradual de pods.
- `27-hello-node-v2-http.txt`: respuestas de la versión 2.
- `30-minikube-estado-final.txt`: Minikube detenido al terminar.

## Respuestas rápidas

**¿Por qué se usó Minikube?**  
Porque permite practicar Kubernetes en un solo equipo y mantiene las mismas ideas principales de un clúster real.

**¿Por qué se configuró ARM64?**  
Porque el equipo anfitrión es un Mac con Apple Silicon y la máquina virtual usa esa arquitectura.

**¿Cómo se comprobó el balanceo?**  
Se levantaron cuatro réplicas y se hicieron varias peticiones. Las respuestas mostraron nombres de pods distintos.

**¿Qué demostró la actualización gradual?**  
Que Kubernetes reemplazó los pods de la versión 1 por pods de la versión 2 sin interrumpir el acceso al servicio.

**¿La práctica de GPU se ejecutó?**  
No forma parte de los pasos de Minikube y requiere una GPU NVIDIA visible para Linux. Los archivos suministrados se conservaron como referencia, sin modificar el equipo.

## Cómo volver a iniciar una demostración

Desde la máquina virtual:

```bash
minikube start --driver=docker
kubectl apply -f hello-minikube/
kubectl apply -f hello-node/deployment.yaml
kubectl apply -f hello-node/service.yaml
```

Al terminar:

```bash
kubectl delete -f hello-node/ --ignore-not-found
kubectl delete -f hello-minikube/ --ignore-not-found
minikube stop
```
