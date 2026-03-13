minikube start --driver=docker --cpus=4 --memory=8192 --disk-size=40g
minikube addons enable ingress
minikube addons enable metrics-server

kubectl create namespace aidp --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace observability --dry-run=client -o yaml | kubectl apply -f -

kubectl get nodes
kubectl get pods -n ingress-nginx