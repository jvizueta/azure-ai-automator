#Azure AI Automator
Azure AI Automation using n8n on Azure AKS using Helm and Terraform

## TODO List:
- Create Azure Pg DB with Terraform as an option to CNPG
- Create the A Record with Terraform
- Helm cmds to bash script

## Prerequisites

### Check AKS availability

```
az aks get-credentials --resource-group <your-resource-group> --name <your-aks-cluster-name>
kubectl get nodes
```

### Cloud Native PG installation (if Azure PG DB not used)
Recommended version of Cloud Native PG is v1.25.1 for mid-2025

```
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg \
  --set installCRDs=true
kubectl get crd poolers.postgresql.cnpg.io
helm list -n cnpg-system
kubectl get deployments -n cnpg-system
# kubectl rollout restart deployment cnpg-cloudnative-pg -n cnpg-system
kubectl get endpoints cnpg-webhook-service -n cnpg-system

# kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.25/releases/cnpg-1.25.1.yaml

kubectl get crds | grep pooler

```

### NGINX Ingress Controller

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --set controller.ingressClass=nginx
kubectl get svc nginx-ingress-nginx-controller -n ingress-nginx
```

Sample output:
```
# kubectl get svc nginx-ingress-nginx-controller -n ingress-nginx
NAME                             TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
nginx-ingress-nginx-controller   LoadBalancer   10.0.147.162   48.216.180.192   80:32194/TCP,443:32244/TCP   9m36s
```

Copy the EXTERNAL-IP

### Create the A Record in Azure DNS

1. Option A: Azure Portal
1. Go to Azure Portal → DNS Zones
1. Select your zone: azure.lab.zivra.com
1. Click + Record Set
1. Fill in:
1.1. Name: n8n (this makes n8n.azure.lab.zivra.com)
1.1. Type: A
1.1. TTL: 300
1.1. IP address: Paste the ingress external IP
1. Click OK


# Option B: Azure CLI

```
az network dns record-set a add-record \
  --resource-group <your-resource-group-where-the-zone-name-lives> \
  --zone-name azure.lab.zivra.com \
  --record-set-name n8n-jc \
  --ipv4-address <INGRESS_EXTERNAL_IP>
```

Then test it:

```
nslookup n8n-jc.azure.lab.zivra.com
dig +short n8n-jc.azure.lab.zivra.com
``


### Cert-Manager
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

### Let's Encrypt Cluster Issuer

```
kubectl apply -f cluster-issuer.yaml
kubectl get clusterissuer letsencrypt-prod
kubectl describe clusterissuer letsencrypt-prod
```

### CA cert

```
# cnpg-system is the CNPG default installation namespace
kubectl get secrets -n cnpg-system

NAME                TYPE                DATA   AGE
cnpg-ca-secret      Opaque              2      154m
cnpg-webhook-cert   kubernetes.io/tls   2      154m

kubectl get secret cnpg-ca-secret -n cnpg-system -o jsonpath="{.data.ca\.crt}" | base64 -d > ca.crt
kubectl create namespace automations
kubectl create secret generic db-ca --from-file=ca.crt=ca.crt -n automations
kubectl get secret db-ca -n automations

NAME    TYPE     DATA   AGE
db-ca   Opaque   1      14s


kubectl get secret db-ca -n automations -o jsonpath="{.data.ca\.crt}" | base64 -d > ca.crt

kubectl create secret generic db-app --from-literal=password=<your-db-password> -n automations

```


### n8n Prod Installation in AKS

helm install my-n8n oci://8gears.container-registry.com/library/n8n --version 1.0.7 --namespace automations -f values-production.yaml


