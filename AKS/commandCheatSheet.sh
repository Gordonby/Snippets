# change service type
```bash
kubectl patch svc myservice  -p '{"spec": {"type": "LoadBalancer"}}'

kubectl patch svc myservice  -p '{"spec": {"type": "ClusterIP"}}'
```

#lookup images in the mcr (good for when behind az fw)
```bash
wget -O - https://mcr.microsoft.com/v2/_catalog | grep busybox
wget -O - https://mcr.microsoft.com/v2/aks/e2e/library-busybox/tags/list
```

#busybox for debugging.  ping/dns/wget-magic :D
```bash
kubectl run -i --tty --rm debug --image=mcr.microsoft.com/aks/e2e/library-busybox:master.210526.1 --restart=Never -- sh
```

#Create Namespace if exists
```bash
kubectl create namespace $NAMESP --dry-run=client -o yaml | kubectl apply -f -
```
