#Specify SMB share info
smbServerAddress="172.21.1.37"
shareName="SmbShare"

#Install driver to existing cluster
helm repo add csi-driver-smb https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts
helm install csi-driver-smb csi-driver-smb/csi-driver-smb --namespace kube-system --version v1.5.0

#Create PV
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
" | kubectl apply -f -

kubectl get pv
