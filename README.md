# Installation

## Azure

- Installer [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) selon votre OS

- Connexion à Azure
    
```bash
  az login
```

## Récuperer le projet

```bash
  git clone git@github.com:ESGI-WEB/devops.git
```

## Installation grace à la configuration Terraform

- Se placer dans le dossier terraform du projet

```bash
  cd devops/terraform
```

- Initialisation de Terraform

```bash
  terraform init
```

- Création de l'infrastructure

```bash
  terraform plan
```

Si tout est ok, il est possible d'apply.
A ce niveau, toutes les ressouces devraient être créées, aucune suppression devrait être suggérée par le plan.
Vous devres confirmer l'apply en écrivant "yes"
```bash
  terraform apply
```

- Récupérer l'adresse IP affiché dans les outputs, vous devriez avoir quelque chose comme ça : 

```
  Apply complete! Resources: x added, x changed, x destroyed.

  Outputs:

  public_ip_address = "xxx.xxx.xxx.xxx" <- copiez cette adresse IP
```

Elle servira à vérifier que l'application est bien accessible a l'aide de votre navigateur ou d'un curl

## Docker

Il est nécessaire d'avoir docker d'installé sur votre machine pour pouvoir build les images et les push sur le registry.

- Vous connecter au registry Azure que nous avons créé avec Terraform

```bash
  az acr login --name registrywadouxmorin
```

- Si vous êtes toujours dans le dossier terrafom, revenez à la racine du projet, puis dans le dossier flask-app

```bash
  cd ../flask-app
```

- Build l'image docker

```bash
  docker build -t registrywadouxmorin.azurecr.io/flask-app:latest .
```

- Push l'image sur le registry

```bash
  docker push registrywadouxmorin.azurecr.io/flask-app:latest
```

## Connexion au cluster Kubernetes

- Récupérer les credentials du cluster, cela aura pour effet de créer un fichier de configuration kube vous permettant de vous connecter au cluster

```bash
  az aks get-credentials --overwrite-existing -n AKSCluster -g rg-esgi-wadoux-morin
```

## Installer l'ingress avec Helm

- Ajouter l'ingress controller au repo helm

```bash
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```

- Mettre à jour les repos helm

```bash
  helm repo update
```

## Déploiement de l'application

- Mettre en place l'ingress controller
```bash
    cd ../terraform
```

```bash
    ip_address=$(terraform output -raw public_ip_address)
    
    # Installer Helm avec l'adresse IP récupérée
    helm install ingress-nginx ingress-nginx/ingress-nginx \
        --namespace ingress-nginx \
        --create-namespace \
        -f controler.yaml \
        --set controller.service.loadBalancerIP=$ip_address
 ```

- Se placer dans le dossier kubernetes du projet

```bash
  cd ../kubernetes
```

- Appliquer les fichiers de configuration kubernetes

```bash
  kubectl apply -f .
```

## Vérification

- Vous pouvez verifier que l'ip publique du load balancer est la bonne avec :

```bash
  kubectl get service ingress-nginx-controller -n ingress-nginx
```

- Vérifier que l'application est bien accessible via
    
```bash
    curl $ip_address
```

Vous devriez avoir un retour de ce type :

```
  This webpage has been viewed <X> time(s)
```

Dans le navigateur : http://<ADRESSE_IP_OUTPUT>

## Suppression de l'infrastructure

- Supprimer les ressources kubernetes (en etant dans le dossier /kubernetes)

```bash
  kubectl delete -f .
```

- Supprimer l'ingress controller

```bash
  helm uninstall ingress-nginx --namespace ingress-nginx
```

- Supprimer les ressources Azure avec Terraform

```bash
  cd ../terraform && terraform destroy
```