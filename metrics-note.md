
# Kuberenetes Design Proposal [!!!!]

https://github.com/kubernetes/design-proposals-archive/tree/main


# Doc

## Design proposal

https://github.com/kubernetes/design-proposals-archive/tree/main/instrumentation

### [TODO] details

### monitoring architecture



- Note
  - https://github.com/kubernetes/design-proposals-archive/blob/main/instrumentation/monitoring_architecture.md
- Diagram
  - https://raw.githubusercontent.com/kubernetes/design-proposals-archive/main/instrumentation/monitoring_architecture.png
- 




## k8s.io

https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/

## stackoverflow about metrics not being scraped and the dropper

https://stackoverflow.com/questions/76474371/why-are-many-cadvisor-metrics-not-being-scraped


## Good github post about the cAdvisor metrics

https://github.com/google/cadvisor/issues/1704#

## cAdvisor official

https://github.com/google/cadvisor/blob/master/docs/storage/prometheus.md


### CAdvisor + Prometheus

- Prometheus has the following metric sources on a node:
  - core and non-core system metrics from cAdvisor
  - service metrics exposed by containers via HTTP handler in Prometheus format
  - [optional] metrics about node itself from Node Exporter (a Prometheus component)

### THE ARCHITECTURE !!!

https://raw.githubusercontent.com/kubernetes/design-proposals-archive/main/instrumentation/monitoring_architecture.png

- [TODO] Draw out the drawio

# Note

## How cAdvisor works with containerd



# Test

## Get node stats
```bash
# Get the clusterrole having the nodes/stats permission
kubectl get clusterrole -oyaml | grep nodes/stats -C 50

## The clusterrole system:kubelet-api-admin is needed to get the node stats
kubectl get clusterrole system:kubelet-api-admin

## Create the service account and clusterrolebinding
kubectl apply -f sa-crb-kubelet-stats.yaml

## Get the token from the service account
kubelet_api_token=$(kubectl -n kubgo create token sa-kubelet-api-admin)

## Get the node stats
curl https://$NODE_IP:10250/stats/summary -H "Authorization: Bearer $kubelet_api_token" -k

```

```yaml
# sa-crb-kubelet-stats.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: sa-kubelet-api-admin-bind
subjects:
- kind: ServiceAccount``
  name: sa-kubelet-api-admin
  namespace: kubgo
roleRef:
  kind: ClusterRole
  name: system:kubelet-api-admin
  apiGroup: rbac.authorization.k8s.io
---
# Service Account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa-kubelet-api-admin
  namespace: kubgo

```


## Get the service account token


## Get CAdvisor metrics from AKS node

```bash


## get the token from the metrics server service account

metric_token=$(kubectl -n kube-system create token metrics-server)

## get kubelet metric endpoint

curl https://$NODE_IP:10250/metrics -H "Authorization: Bearer $metric_token" -kv 

## get cAdvisor metric endpoint and types

curl https://$NODE_IP:10250/metrics/cadvisor -H "Authorization: Bearer $metric_token" -k | grep -E '# TYPE|# HELP'

```

### Sample Output

TYPE cadvisor_version_info gauge
TYPE container_blkio_device_usage_total counter
TYPE container_cpu_cfs_periods_total counter
TYPE container_cpu_cfs_throttled_periods_total counter
TYPE container_cpu_cfs_throttled_seconds_total counter
TYPE container_cpu_load_average_10s gauge
TYPE container_cpu_system_seconds_total counter
TYPE container_cpu_usage_seconds_total counter
TYPE container_cpu_user_seconds_total counter
TYPE container_file_descriptors gauge
TYPE container_fs_inodes_free gauge
TYPE container_fs_inodes_total gauge
TYPE container_fs_io_current gauge
TYPE container_fs_io_time_seconds_total counter
TYPE container_fs_io_time_weighted_seconds_total counter
TYPE container_fs_limit_bytes gauge
TYPE container_fs_read_seconds_total counter
TYPE container_fs_reads_bytes_total counter
TYPE container_fs_reads_merged_total counter
TYPE container_fs_reads_total counter
TYPE container_fs_sector_reads_total counter
TYPE container_fs_sector_writes_total counter
TYPE container_fs_usage_bytes gauge
TYPE container_fs_write_seconds_total counter
TYPE container_fs_writes_bytes_total counter
TYPE container_fs_writes_merged_total counter
TYPE container_fs_writes_total counter
TYPE container_last_seen gauge
TYPE container_memory_cache gauge
TYPE container_memory_failcnt counter
TYPE container_memory_failures_total counter
TYPE container_memory_mapped_file gauge
TYPE container_memory_max_usage_bytes gauge
TYPE container_memory_rss gauge
TYPE container_memory_swap gauge
TYPE container_memory_usage_bytes gauge
TYPE container_memory_working_set_bytes gauge
TYPE container_network_receive_bytes_total counter
TYPE container_network_receive_errors_total counter
TYPE container_network_receive_packets_dropped_total counter
TYPE container_network_receive_packets_total counter
TYPE container_network_transmit_bytes_total counter
TYPE container_network_transmit_errors_total counter
TYPE container_network_transmit_packets_dropped_total counter
TYPE container_network_transmit_packets_total counter
TYPE container_oom_events_total counter
TYPE container_processes gauge
TYPE container_scrape_error gauge
TYPE container_sockets gauge
TYPE container_spec_cpu_period gauge
TYPE container_spec_cpu_quota gauge
TYPE container_spec_cpu_shares gauge
TYPE container_spec_memory_limit_bytes gauge
TYPE container_spec_memory_reservation_limit_bytes gauge
TYPE container_spec_memory_swap_limit_bytes gauge
TYPE container_start_time_seconds gauge
TYPE container_tasks_state gauge
TYPE container_threads gauge
TYPE container_threads_max gauge
TYPE container_ulimits_soft gauge
TYPE machine_cpu_cores gauge
TYPE machine_cpu_physical_cores gauge
TYPE machine_cpu_sockets gauge
TYPE machine_memory_bytes gauge
TYPE machine_nvm_avg_power_budget_watts gauge
TYPE machine_nvm_capacity gauge
TYPE machine_scrape_error gauge


## other metrics endpoint from kubelet

/metrics/cadvisor is for detailed container-level metrics and overall node resource usage.
/metrics/resource provides a more aggregated view of resource usage at the pod and node level.
/metrics/probes focuses on the health and availability of pods as indicated by Kubernetes probes.