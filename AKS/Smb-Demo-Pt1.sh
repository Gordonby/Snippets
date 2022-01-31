#This adds the SMB driver, and 3x Persistent Volumes.

#Prerequisites
#2 secrets.
#1. proper - kubectl create secret generic smbcreds --from-literal username=USERNAME --from-literal password="PASSWORD"
#2. arbitary/anon - https://github.com/Gordonby/Snippets/blob/master/AKS/CreateOpaqueSecret.yaml

#Specify SMB share info
smbServerAddress="172.21.1.37"
shareName="SmbShare"
anonShareName="anon"

#Install driver to existing cluster
helm repo add csi-driver-smb https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts
helm install csi-driver-smb csi-driver-smb/csi-driver-smb --namespace kube-system --version v1.5.0

#Create PV for authenticated share
echo "
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-smb-gord-demo
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  mountOptions:
    - dir_mode=0777
    - file_mode=0777
    - vers=3.0
  csi:
    driver: smb.csi.k8s.io
    readOnly: false
    volumeHandle: gord-smb-demo1
    volumeAttributes:
      source: "//$smbServerAddress/$shareName"
    nodeStageSecretRef:
      name: smbcreds
      namespace: default
" | kubectl apply -f -

#Create PV for unauthenticated share (no secretRef)
echo "
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-smb-gord-demo-anon-no-creds
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  mountOptions:
    - dir_mode=0777
    - file_mode=0777
    - vers=3.0
  csi:
    driver: smb.csi.k8s.io
    readOnly: false
    volumeHandle: gord-smb-demo-anon1
    volumeAttributes:
      source: "//$smbServerAddress/$anonShareName"
" | kubectl apply -f -

#Create PV for unauthenticated share (arbitary secretRef)
echo "
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-smb-gord-demo-anon-arb-creds
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  mountOptions:
    - dir_mode=0777
    - file_mode=0777
    - vers=3.0
  csi:
    driver: smb.csi.k8s.io
    readOnly: false
    volumeHandle: gord-smb-demo-anon2
    volumeAttributes:
      source: "//$smbServerAddress/$anonShareName"
    nodeStageSecretRef:
      name: smbcredsanon
      namespace: default
" | kubectl apply -f -

kubectl get pv
kubectl get secrets
