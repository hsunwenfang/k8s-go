

# substitute-kublet-in-aks


- ssh access to the vmss nodes without debug container
    - generate ssh key pair
        - Azure Portal > VMSS > Reset Password
    - update vmss to the latest image
        - az vmss update-instances -g MC_HSUN_HSUNPRIVATECNIAKS_EASTASIA -n aks-master-28888923-vmss --instance-ids "*"
    - Clean ssh known_hosts
        - ssh-keygen -f "/home/hsunwen/.ssh/known_hosts" -R "10.224.1.138"
    - ssh to the vmss node
        - ssh -vvv -F .ssh/aksconfig aks-master-28888923-vmss00000m

- How to make target in kubernetes repo
    - Doc
        - https://taesunny.github.io/kubernetes/how-to-build-and-install-kubelet/
    - Git clone and checkout to the version
        - git checkout v1.27.7
    - Makefile
        - build/root/Makefile
    - Script for 'make all'
        - hack/make-rules/build.sh
    - Make a binary (Options are in build/root/Makefile)
        - make all WHAT=cmd/kubelet GOFLAGS=-v

- Build kubelet with my message
    - Add some msgs
        - cmd/kubelet/app/server.go
            - fmt.Printf("Hello, world.\n")
    - Make kubelet
        - make all WHAT=cmd/kubelet GOFLAGS=-v
    - Copy kubelet to the vmss nodes
        - scp -F ~/.ssh/aksconfig ~/kubernetes/_output/local/go/bin/kubelet aks-master-28888923-vmss00000m:/home/azureuser/kubelet
    - Replace kubelet in the vmss nodes
        - mv /usr/local/bin/kubelet /usr/local/bin/kubelet_prd; cp /home/azureuser/kubelet /usr/local/bin/kubelet; systemctl restart kubelet.service
    - Check kubelet log from start time
        - journalctl -u kubelet.service --since "2024-01-16 13:11:00"


# Remark

- Error when building a kubelet using the wrong vresion
    - master-28888923-vmss00000M kubelet[132336]: E0116 08:35:41.070930  132336 run.go:74] "command failed" err="failed to set feature gates from initial flags-based config: unrecognized feature gate: CSIMigrationAzureFile"
    - This arises from the kubelet version is not matched with the apiserver version
- 