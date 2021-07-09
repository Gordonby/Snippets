#busybox for debugging.  ping/dns/wget-magic :D
#using mcr hosted for when behind az fw.
kubectl run -i --tty --rm debug --image=mcr.microsoft.com/aks/e2e/library-busybox:master.210526.1 --restart=Never -- sh

