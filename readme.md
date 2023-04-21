```shell
export KUBERAY_VERSION=v0.5.0
kubectl create -k "github.com/ray-project/kuberay/manifests/cluster-scope-resources?ref=${KUBERAY_VERSION}&timeout=90s"
kubectl apply -k "github.com/ray-project/kuberay/manifests/base?ref=${KUBERAY_VERSION}&timeout=90s"
```

[GPU on GKE Autopilot limitation](https://cloud.google.com/kubernetes-engine/docs/how-to/autopilot-gpus#limitations)



```
kubectl create serviceaccount worker \
    --namespace default
kubectl annotate serviceaccount worker \
    --namespace default \
    iam.gke.io/gcp-service-account=gke-wi@<PROJECT_ID>.iam.gserviceaccount.com
```