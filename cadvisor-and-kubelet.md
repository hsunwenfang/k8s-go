

# Relationship

![cadvisor-cgroup-code.drawio.svg](cadvisor-cgroup-code.drawio.svg)

## A. Support only some subsets

- Script
    - https://github.com/google/cadvisor/blob/master/container/factory.go#L108
- Summary
    - Includes all cAdvisor supported metrics
- MatricSet and MatricKind
    - includedMetrics := cadvisormetrics.MetricSet

## B. Cadvisor read cgroup metrics from cgroupfs



# kubulet

## kubelet k8s pkg

https://github.com/kubernetes/kubernetes/tree/331e5561ab2c6e94a598997cc4526a8194f767ea/pkg/kubelet

- https://github.com/kubernetes/kubernetes/blob/331e5561ab2c6e94a598997cc4526a8194f767ea/pkg/kubelet/status/generate.go
    - generatePodStatus


## kubelet


# cAdvisor and cgroup

- GetCgroupSubsystems
    - https://github.com/google/cadvisor/blob/04006e563ea6c1b7b28a47854afc09f246e527de/container/libcontainer/helpers.go#L32


# cgroup

- cgroup v2 doc [TODO]
    - https://github.com/opencontainers/runc/blob/main/docs/cgroup-v2.md

- cgroup metrics overview
    - https://github.com/opencontainers/runc/blob/main/libcontainer/cgroups/stats.go
    - CpuStats vs CPUSetStats
        - CpuStats
            - CPU usage statistics like cpu time used, number of times the container has been throttled, etc.
        - CPUSetStats
            - It includes information such as the list of CPU cores that the container is allowed to execute on.

- cgroup of a pod
    - /sys/fs/cgroup/kubepods.slice/kubepods-pod8881058d_1e47_4c63_b936_ce9376632715.slice
    - /sys/fs/cgroup/kubepods.slice/kubepods-pod<podUID>.slice
        - podID = kubectl get po <pod_name> -ojson | jq .metadata.uid

- dbus in cgroup
    - https://github.com/opencontainers/runc/blob/main/libcontainer/cgroups/systemd/dbus.go#L20
    - dbusC        *systemdDbus.Conn
        - a connection to the systemd's D-Bus API
    - dbusMu       sync.RWMutex
        - specifically a read-write mutex (sync.RWMutex). Mutexes are used to ensure that only one goroutine accesses a shared resource at a time, to prevent race conditions.
    - dbusInited   bool
    - dbusRootless bool
        - root privilege is not required to use the D-Bus API
        - rootless state should be the same for all cgroups in the same cgroup tree
        - rootless state is determined by the rootlessCgroup() function
        - rootless state should be uniform between state changes

# cAdvisor

- Where kubelet calls cAdvisor
    - https://github.com/kubernetes/kubernetes/blob/95a159299b9be577be55550dbbca588f25580ae9/pkg/kubelet/cadvisor/cadvisor_linux.go#L80
    - cAdvisor package in this script
        - // Register supported container handlers.
        - _ "github.com/google/cadvisor/container/containerd/install"
        - _ "github.com/google/cadvisor/container/crio/install"
        - _ "github.com/google/cadvisor/container/systemd/install"
        - "github.com/google/cadvisor/cache/memory"
        - cadvisormetrics "github.com/google/cadvisor/container"
        - cadvisorapi "github.com/google/cadvisor/info/v1"
        - cadvisorapiv2 "github.com/google/cadvisor/info/v2"

    - IncludedMetrics
        - cadvisormetrics.CpuUsageMetrics:     struct{}{},
        - cadvisormetrics.MemoryUsageMetrics:  struct{}{},
		- cadvisormetrics.CpuLoadMetrics:      struct{}{},
		- cadvisormetrics.DiskIOMetrics:       struct{}{},
		- cadvisormetrics.NetworkUsageMetrics: struct{}{},
		- cadvisormetrics.AppMetrics:          struct{}{},
		- cadvisormetrics.ProcessMetrics:      struct{}{},
		- cadvisormetrics.OOMMetrics:          struct{}{},

- Where cAdvisor calls cont
- cAdvisor | handlers.go
    - https://github.com/google/cadvisor/blob/04006e563ea6c1b7b28a47854afc09f246e527de/container/libcontainer/handler.go#L917
    - cAdvisor uses libcontainer to get the container info
        - https://github.com/google/cadvisor/blob/04006e563ea6c1b7b28a47854afc09f246e527de/container/libcontainer/handler.go#L15
        - libcontainer is a Go library for container lifecycle management
            - GitHub: https://github.com/opencontainers/runc/tree/main/libcontainer
            - Can be mapped to 'crictl inspect' command
    - 

- cAdvisor | containerd.go
    - 

- About libcontainer
    - has Linux Capability

# TODO

- runc link
    - https://github.com/opencontainers/runc
- How to use runc to run a container
    - [TODO]