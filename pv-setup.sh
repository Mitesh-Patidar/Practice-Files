#!/bin/bash

echo "Practice Script for PV setup and PVC claim. Manual PV provisioning (Static Provisioning). By - Mitesh"
echo "Creating host path directory..."
sudo mkdir -p /mnt/data
sudo chmod 777 /mnt/data

echo "Creating PV.yml manifest file."
cat <<EOF > pv.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: static-PV
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
EOF

echo "Creating PVC.yml manifest file."
cat <<EOF > pvc.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: static-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

echo "Creating app-deployment.yml manifest file."
cat <<EOF > app-dep.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-pv-dep
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx-with-PV-containers
          image: nginx
          ports:
            - containerPort: 80
          volumeMounts:
            - name: logical-storage
              mountPath: /usr/share/nginx/html
    volumes:
      - name: logical-storage
        persistentVolumeClaim:
          claimName: static-pvc
EOF

echo "Applying all manifests..."
kubectl apply -f pv.yml
kubectl apply -f pvc.yml
kubectl apply -f app-deployment.yml

echo "Checking resources..."
kubectl get pv
kubectl get pvc
kubectl get pods
