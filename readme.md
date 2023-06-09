# Use kuberay with GKE Autopilot

## Limitations
There are some existing [limitations](https://cloud.google.com/kubernetes-engine/docs/how-to/autopilot-gpus#limitations) to run GPU on GKE Autopilot. Please check before proceeding

## Create infrastructure
```shell
cd terraform
terraform apply
```

## Deploy kuberay operator to the cluster
```shell
gcloud container clusters get-credentials [CLUSTER_NAME] --location=[REGION]
export KUBERAY_VERSION=v0.5.0
kubectl create -k "github.com/ray-project/kuberay/manifests/cluster-scope-resources?ref=${KUBERAY_VERSION}&timeout=90s"
kubectl apply -k "github.com/ray-project/kuberay/manifests/base?ref=${KUBERAY_VERSION}&timeout=90s"
```

## Create kuberay cluster on the GKE cluster
```shell
kubectl apply -f ray-cluster.autoscaler.large.yaml
```
More samples can be found [here](https://github.com/ray-project/kuberay/tree/master/ray-operator/config/samples)
Get the public IP address to connect to the cluster:
```shell
kubectl get svc raycluster-kuberay-head-svc
```

## Initiate your workload from remote location
```
!pip install -U "ray[default]"
```
Sample code:
```python
# This example showcases how to use Tensorflow with Ray Train.
# Original code:
# https://www.tensorflow.org/tutorials/distribute/multi_worker_with_keras
import argparse
from filelock import FileLock
import json
import os

import numpy as np
from ray.air.result import Result
import tensorflow as tf

from ray.train.tensorflow import TensorflowTrainer
from ray.air.integrations.keras import ReportCheckpointCallback
from ray.air.config import ScalingConfig


def mnist_dataset(batch_size: int) -> tf.data.Dataset:
    with FileLock(os.path.expanduser("~/.mnist_lock")):
        (x_train, y_train), _ = tf.keras.datasets.mnist.load_data()
    # The `x` arrays are in uint8 and have values in the [0, 255] range.
    # You need to convert them to float32 with values in the [0, 1] range.
    x_train = x_train / np.float32(255)
    y_train = y_train.astype(np.int64)
    train_dataset = (
        tf.data.Dataset.from_tensor_slices((x_train, y_train))
        .shuffle(60000)
        .repeat()
        .batch(batch_size)
    )
    return train_dataset


def build_cnn_model() -> tf.keras.Model:
    model = tf.keras.Sequential(
        [
            tf.keras.Input(shape=(28, 28)),
            tf.keras.layers.Reshape(target_shape=(28, 28, 1)),
            tf.keras.layers.Conv2D(32, 3, activation="relu"),
            tf.keras.layers.Flatten(),
            tf.keras.layers.Dense(128, activation="relu"),
            tf.keras.layers.Dense(10),
        ]
    )
    return model


def train_func(config: dict):
    per_worker_batch_size = config.get("batch_size", 64)
    epochs = config.get("epochs", 3)
    steps_per_epoch = config.get("steps_per_epoch", 70)

    tf_config = json.loads(os.environ["TF_CONFIG"])
    num_workers = len(tf_config["cluster"]["worker"])

    strategy = tf.distribute.MultiWorkerMirroredStrategy()

    global_batch_size = per_worker_batch_size * num_workers
    multi_worker_dataset = mnist_dataset(global_batch_size)

    with strategy.scope():
        # Model building/compiling need to be within `strategy.scope()`.
        multi_worker_model = build_cnn_model()
        learning_rate = config.get("lr", 0.001)
        multi_worker_model.compile(
            loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
            optimizer=tf.keras.optimizers.SGD(learning_rate=learning_rate),
            metrics=["accuracy"],
        )

    history = multi_worker_model.fit(
        multi_worker_dataset,
        epochs=epochs,
        steps_per_epoch=steps_per_epoch,
        callbacks=[ReportCheckpointCallback()],
    )
    results = history.history
    return results


def train_tensorflow_mnist(
    num_workers: int = 2, use_gpu: bool = False, epochs: int = 4
) -> Result:
    config = {"lr": 1e-3, "batch_size": 64, "epochs": epochs}
    trainer = TensorflowTrainer(
        train_loop_per_worker=train_func,
        train_loop_config=config,
        scaling_config=ScalingConfig(num_workers=num_workers, use_gpu=use_gpu),
    )
    results = trainer.fit()
    return results


if __name__ == "__main__":


    import ray
    ray.init(address="ray://<Ray Head IP>:8265")
    train_tensorflow_mnist(
        num_workers=2, use_gpu=True
    )

```


## Let your Ray workload use a GCP Service Account to access other GCP services
```
kubectl create serviceaccount worker \
    --namespace default
kubectl annotate serviceaccount worker \
    --namespace default \
    iam.gke.io/gcp-service-account=gke-wi@<PROJECT_ID>.iam.gserviceaccount.com
```
