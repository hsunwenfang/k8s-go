
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

## All the kubelet endpoints in /pkg/kubelet/server/server_test.go/TestMetricsBuckets

```go

func TestMetricBuckets(t *testing.T) {
	tests := map[string]struct {
		url    string
		bucket string
	}{
		"healthz endpoint":                {url: "/healthz", bucket: "healthz"},
		"attach":                          {url: "/attach/podNamespace/podID/containerName", bucket: "attach"},
		"attach with uid":                 {url: "/attach/podNamespace/podID/uid/containerName", bucket: "attach"},
		"configz":                         {url: "/configz", bucket: "configz"},
		"containerLogs":                   {url: "/containerLogs/podNamespace/podID/containerName", bucket: "containerLogs"},
		"debug v flags":                   {url: "/debug/flags/v", bucket: "debug"},
		"pprof with sub":                  {url: "/debug/pprof/subpath", bucket: "debug"},
		"exec":                            {url: "/exec/podNamespace/podID/containerName", bucket: "exec"},
		"exec with uid":                   {url: "/exec/podNamespace/podID/uid/containerName", bucket: "exec"},
		"healthz":                         {url: "/healthz/", bucket: "healthz"},
		"healthz log sub":                 {url: "/healthz/log", bucket: "healthz"},
		"healthz ping":                    {url: "/healthz/ping", bucket: "healthz"},
		"healthz sync loop":               {url: "/healthz/syncloop", bucket: "healthz"},
		"logs":                            {url: "/logs/", bucket: "logs"},
		"logs with path":                  {url: "/logs/logpath", bucket: "logs"},
		"metrics":                         {url: "/metrics", bucket: "metrics"},
		"metrics cadvisor sub":            {url: "/metrics/cadvisor", bucket: "metrics/cadvisor"},
		"metrics probes sub":              {url: "/metrics/probes", bucket: "metrics/probes"},
		"metrics resource sub":            {url: "/metrics/resource", bucket: "metrics/resource"},
		"pods":                            {url: "/pods/", bucket: "pods"},
		"portForward":                     {url: "/portForward/podNamespace/podID", bucket: "portForward"},
		"portForward with uid":            {url: "/portForward/podNamespace/podID/uid", bucket: "portForward"},
		"run":                             {url: "/run/podNamespace/podID/containerName", bucket: "run"},
		"run with uid":                    {url: "/run/podNamespace/podID/uid/containerName", bucket: "run"},
		"runningpods":                     {url: "/runningpods/", bucket: "runningpods"},
		"stats":                           {url: "/stats/", bucket: "stats"},
		"stats summary sub":               {url: "/stats/summary", bucket: "stats"},
		"invalid path":                    {url: "/junk", bucket: "other"},
		"invalid path starting with good": {url: "/healthzjunk", bucket: "other"},
	}
	fw := newServerTest()
	defer fw.testHTTPServer.Close()

	for _, test := range tests {
		path := test.url
		bucket := test.bucket
		require.Equal(t, fw.serverUnderTest.getMetricBucket(path), bucket)
	}
}

```


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

## Get config

```bash
curl https://$NODE_IP:10250/configz -H "Authorization: Bearer $kubelet_api_token" -k | jq .
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

## /pkg/kubelet/metrcis/metrics.go

```go
// Register registers all metrics.
func Register(collectors ...metrics.StableCollector) {
	// Register the metrics.
	registerMetrics.Do(func() {
		legacyregistry.MustRegister(NodeName)
		legacyregistry.MustRegister(PodWorkerDuration)
		legacyregistry.MustRegister(PodStartDuration)
		legacyregistry.MustRegister(PodStartSLIDuration)
		legacyregistry.MustRegister(CgroupManagerDuration)
		legacyregistry.MustRegister(PodWorkerStartDuration)
		legacyregistry.MustRegister(PodStatusSyncDuration)
		legacyregistry.MustRegister(ContainersPerPodCount)
		legacyregistry.MustRegister(PLEGRelistDuration)
		legacyregistry.MustRegister(PLEGDiscardEvents)
		legacyregistry.MustRegister(PLEGRelistInterval)
		legacyregistry.MustRegister(PLEGLastSeen)
		legacyregistry.MustRegister(EventedPLEGConnErr)
		legacyregistry.MustRegister(EventedPLEGConn)
		legacyregistry.MustRegister(EventedPLEGConnLatency)
		legacyregistry.MustRegister(RuntimeOperations)
		legacyregistry.MustRegister(RuntimeOperationsDuration)
		legacyregistry.MustRegister(RuntimeOperationsErrors)
		legacyregistry.MustRegister(Evictions)
		legacyregistry.MustRegister(EvictionStatsAge)
		legacyregistry.MustRegister(Preemptions)
		legacyregistry.MustRegister(DevicePluginRegistrationCount)
		legacyregistry.MustRegister(DevicePluginAllocationDuration)
		legacyregistry.MustRegister(RunningContainerCount)
		legacyregistry.MustRegister(RunningPodCount)
		legacyregistry.MustRegister(DesiredPodCount)
		legacyregistry.MustRegister(ActivePodCount)
		legacyregistry.MustRegister(MirrorPodCount)
		legacyregistry.MustRegister(WorkingPodCount)
		legacyregistry.MustRegister(OrphanedRuntimePodTotal)
		legacyregistry.MustRegister(RestartedPodTotal)
		legacyregistry.MustRegister(ManagedEphemeralContainers)
		if utilfeature.DefaultFeatureGate.Enabled(features.KubeletPodResources) {
			legacyregistry.MustRegister(PodResourcesEndpointRequestsTotalCount)

			if utilfeature.DefaultFeatureGate.Enabled(features.KubeletPodResourcesGetAllocatable) {
				legacyregistry.MustRegister(PodResourcesEndpointRequestsListCount)
				legacyregistry.MustRegister(PodResourcesEndpointRequestsGetAllocatableCount)
				legacyregistry.MustRegister(PodResourcesEndpointErrorsListCount)
				legacyregistry.MustRegister(PodResourcesEndpointErrorsGetAllocatableCount)
			}
			if utilfeature.DefaultFeatureGate.Enabled(features.KubeletPodResourcesGet) {
				legacyregistry.MustRegister(PodResourcesEndpointRequestsGetCount)
				legacyregistry.MustRegister(PodResourcesEndpointErrorsGetCount)
			}
		}
		legacyregistry.MustRegister(StartedPodsTotal)
		legacyregistry.MustRegister(StartedPodsErrorsTotal)
		legacyregistry.MustRegister(StartedContainersTotal)
		legacyregistry.MustRegister(StartedContainersErrorsTotal)
		legacyregistry.MustRegister(StartedHostProcessContainersTotal)
		legacyregistry.MustRegister(StartedHostProcessContainersErrorsTotal)
		legacyregistry.MustRegister(RunPodSandboxDuration)
		legacyregistry.MustRegister(RunPodSandboxErrors)
		legacyregistry.MustRegister(CPUManagerPinningRequestsTotal)
		legacyregistry.MustRegister(CPUManagerPinningErrorsTotal)
		legacyregistry.MustRegister(TopologyManagerAdmissionRequestsTotal)
		legacyregistry.MustRegister(TopologyManagerAdmissionErrorsTotal)
		legacyregistry.MustRegister(TopologyManagerAdmissionDuration)
		legacyregistry.MustRegister(OrphanPodCleanedVolumes)
		legacyregistry.MustRegister(OrphanPodCleanedVolumesErrors)

		for _, collector := range collectors {
			legacyregistry.CustomMustRegister(collector)
		}

		if utilfeature.DefaultFeatureGate.Enabled(features.GracefulNodeShutdown) &&
			utilfeature.DefaultFeatureGate.Enabled(features.GracefulNodeShutdownBasedOnPodPriority) {
			legacyregistry.MustRegister(GracefulShutdownStartTime)
			legacyregistry.MustRegister(GracefulShutdownEndTime)
		}

		if utilfeature.DefaultFeatureGate.Enabled(features.ConsistentHTTPGetHandlers) {
			legacyregistry.MustRegister(LifecycleHandlerHTTPFallbacks)
		}
	})
}
```