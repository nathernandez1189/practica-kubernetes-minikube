#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
EVIDENCE_DIR="$PROJECT_DIR/evidencias"
PROXY_PID=""
PORT_FORWARD_PID=""

mkdir -p "$EVIDENCE_DIR"
cd "$PROJECT_DIR"

cleanup_proxy() {
  if [[ -n "$PROXY_PID" ]]; then
    kill "$PROXY_PID" >/dev/null 2>&1 || true
  fi
  if [[ -n "$PORT_FORWARD_PID" ]]; then
    kill "$PORT_FORWARD_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup_proxy EXIT

minikube start --driver=docker --cpus=2 --memory=2600mb --disk-size=8g

{
  minikube version
  kubectl version
  kubectl cluster-info
} > "$EVIDENCE_DIR/01-versiones-cluster.txt" 2>&1
kubectl get nodes -o wide > "$EVIDENCE_DIR/02-nodos.txt"
kubectl get pods --all-namespaces > "$EVIDENCE_DIR/03-pods-sistema.txt"
kubectl get events --sort-by=.metadata.creationTimestamp > "$EVIDENCE_DIR/04-eventos.txt"
kubectl config view --minify > "$EVIDENCE_DIR/05-kubectl-config.txt"

kubectl apply -f hello-minikube/deployment.yaml -f hello-minikube/service.yaml
kubectl rollout status deployment/hello-minikube --timeout=180s
kubectl get deployment,pod,service -l app=hello-minikube -o wide > "$EVIDENCE_DIR/06-hello-minikube-recursos.txt"
HELLO_MINIKUBE_URL="$(minikube service hello-minikube --url)"
{
  echo "URL=$HELLO_MINIKUBE_URL"
  curl --fail --silent --show-error "$HELLO_MINIKUBE_URL"
} > "$EVIDENCE_DIR/07-hello-minikube-http.txt"
kubectl logs deployment/hello-minikube --tail=30 > "$EVIDENCE_DIR/08-hello-minikube-logs.txt"

minikube addons enable dashboard
kubectl -n kubernetes-dashboard rollout status deployment/kubernetes-dashboard --timeout=240s
kubectl -n kubernetes-dashboard wait --for=condition=Ready pod \
  -l k8s-app=kubernetes-dashboard --timeout=240s
kubectl proxy --address=192.168.100.3 --port=8001 --accept-hosts='.*' > /tmp/kubectl-dashboard-proxy.log 2>&1 &
PROXY_PID="$!"
DASHBOARD_PATH="/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/"
curl --retry 120 --retry-delay 1 --retry-connrefused --retry-all-errors --fail --silent --show-error \
  --output /dev/null --write-out "Dashboard HTTP=%{http_code}\n" \
  "http://192.168.100.3:8001${DASHBOARD_PATH}" > "$EVIDENCE_DIR/09-dashboard-http.txt"
kubectl -n kubernetes-dashboard get deployment,pod,service -o wide > "$EVIDENCE_DIR/10-dashboard-recursos.txt"

minikube image build -t hello-node:v1 hello-node
minikube image build -t hello-node:v2 -f Dockerfile.v2 hello-node
minikube image ls | grep hello-node > "$EVIDENCE_DIR/11-hello-node-imagenes.txt"

kubectl apply -f hello-node/deployment.yaml -f hello-node/service.yaml
kubectl rollout status deployment/hello-node --timeout=180s
HELLO_NODE_URL="$(minikube service hello-node --url)"
{
  echo "URL=$HELLO_NODE_URL"
  curl --fail --silent --show-error "$HELLO_NODE_URL"
} > "$EVIDENCE_DIR/12-hello-node-v1-http.txt"
kubectl get pods,deployments,services -l app=hello-node -o wide > "$EVIDENCE_DIR/13-hello-node-recursos.txt"
kubectl port-forward --address=0.0.0.0 service/hello-node 8090:8080 > /tmp/hello-node-port-forward.log 2>&1 &
PORT_FORWARD_PID="$!"
curl --retry 20 --retry-delay 1 --retry-connrefused --fail --silent --show-error \
  http://192.168.100.3:8090 > "$EVIDENCE_DIR/13-hello-node-port-forward.txt"
kill "$PORT_FORWARD_PID" >/dev/null 2>&1 || true
PORT_FORWARD_PID=""
kubectl describe pods -l app=hello-node > "$EVIDENCE_DIR/14-hello-node-describe-pods.txt"

POD_NAME="$(kubectl get pods -l app=hello-node -o jsonpath='{.items[0].metadata.name}')"
kubectl logs "$POD_NAME" > "$EVIDENCE_DIR/15-hello-node-logs.txt"
kubectl exec "$POD_NAME" -- env > "$EVIDENCE_DIR/16-hello-node-env.txt"
kubectl exec "$POD_NAME" -- cat /app/server.js > "$EVIDENCE_DIR/17-hello-node-server-en-pod.js"
kubectl exec "$POD_NAME" -- wget -qO- http://127.0.0.1:8080 > "$EVIDENCE_DIR/18-hello-node-curl-interno.txt"

kubectl scale deployment/hello-node --replicas=4
kubectl rollout status deployment/hello-node --timeout=180s
kubectl wait --for=condition=Ready pod -l app=hello-node --timeout=180s
kubectl get pods -l app=hello-node -o wide > "$EVIDENCE_DIR/19-escalado-cuatro-pods.txt"
for _ in {1..12}; do
  curl --fail --silent --show-error "$HELLO_NODE_URL"
done > "$EVIDENCE_DIR/20-balanceo-cuatro-pods.txt"

kubectl scale deployment/hello-node --replicas=2
kubectl rollout status deployment/hello-node --timeout=180s
kubectl get pods -l app=hello-node -o wide > "$EVIDENCE_DIR/21-scale-down-dos-pods.txt"

minikube addons enable ingress
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=300s
kubectl apply -f ingress/ingress.yaml
MINIKUBE_IP="$(minikube ip)"
for _ in {1..60}; do
  if curl --fail --silent --header 'Host: practica.local' "http://${MINIKUBE_IP}/node" >/dev/null; then
    break
  fi
  sleep 2
done
{
  echo "Ingress IP=$MINIKUBE_IP Host=practica.local"
  echo "--- /node ---"
  curl --fail --silent --show-error --header 'Host: practica.local' "http://${MINIKUBE_IP}/node"
  echo "--- /echo ---"
  curl --fail --silent --show-error --header 'Host: practica.local' "http://${MINIKUBE_IP}/echo"
} > "$EVIDENCE_DIR/22-ingress-rutas.txt"
kubectl get ingress practica-ingress -o wide > "$EVIDENCE_DIR/23-ingress-recurso.txt"
kubectl -n ingress-nginx get pods -o wide > "$EVIDENCE_DIR/24-ingress-controller.txt"

kubectl scale deployment/hello-node --replicas=4
kubectl rollout status deployment/hello-node --timeout=180s
kubectl annotate deployment/hello-node kubernetes.io/change-cause='Rolling update hello-node v1 a v2' --overwrite
kubectl set image deployment/hello-node hello-node=hello-node:v2
kubectl rollout status deployment/hello-node --timeout=240s
kubectl rollout history deployment/hello-node > "$EVIDENCE_DIR/25-rolling-update-historial.txt"
kubectl get pods -l app=hello-node -o wide > "$EVIDENCE_DIR/26-rolling-update-pods.txt"
for _ in {1..8}; do
  curl --fail --silent --show-error "$HELLO_NODE_URL"
done > "$EVIDENCE_DIR/27-rolling-update-v2-http.txt"

kubectl delete ingress practica-ingress
kubectl delete service,deployment hello-node hello-minikube
kubectl wait --for=delete pod -l app=hello-node --timeout=120s || true
kubectl wait --for=delete pod -l app=hello-minikube --timeout=120s || true
kubectl get pods,services > "$EVIDENCE_DIR/28-limpieza-kubernetes.txt"
cleanup_proxy
PROXY_PID=""
minikube stop > "$EVIDENCE_DIR/29-minikube-stop.txt"
minikube status > "$EVIDENCE_DIR/30-minikube-estado-final.txt" 2>&1 || true

echo "Práctica Kubernetes completada y Minikube detenido."
