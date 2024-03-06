#!/bin/bash
set -ex

download_and_customize_script() {
    local url="https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/${INSTALL_SCRIPT}/install_master.sh"
    local script
    script=$(curl -s "$url")

    script=$(echo "$script" | set_shebang)
    script=$(echo "$script" | adjust_architecture)
    script=$(echo "$script" | customize_kubeadm_init)
    script=$(echo "$script" | add_trivy)
    script=$(echo "$script" | add_falco)
    script=$(echo "$script" | fix_rm_usage)

    echo "$script"
}

set_shebang() {
    sed '1s/^#!\/bin\/sh/#!\/bin\/bash/'
}

adjust_architecture() {
    local arch=$(uname -m)
    if [[ "$arch" == "arm64" || "$arch" == "aarch64" ]]; then
        sed 's/amd64/arm64/g'
    else
        cat
    fi
}

customize_kubeadm_init() {
    awk '/kubeadm init/ {
        if (!match($0, /--apiserver-advertise-address=/)) {
            $0 = $0 " --apiserver-advertise-address=192.168.5.10"
        } else {
            gsub(/--apiserver-advertise-address=[^ ]+/, "--apiserver-advertise-address=192.168.5.10")
        }
    }1'
}

add_trivy() {
    sed '/apt-mark hold kubelet kubeadm kubectl kubernetes-cni/a \
    # Trivy installation \n \
    mkdir -p /etc/apt/keyrings\n \
    curl -fsSL https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --batch --dearmor -o /etc/apt/keyrings/trivy.gpg\n \
    echo deb [signed-by=/etc/apt/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list\n \
    apt-get update\n \
    apt-get install -y trivy'
}

add_falco() {
    sed '/apt-mark hold kubelet kubeadm kubectl kubernetes-cni/a \
    # Falco installation \n \
    mkdir -p /etc/apt/keyrings\n \
    curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | sudo gpg --batch --dearmor -o /etc/apt/keyrings/falco-archive-keyring.gpg\n \
    echo deb [signed-by=/etc/apt/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list\n \
    apt-get update\n \
    FALCO_FRONTEND=noninteractive FALCO_DRIVER_CHOICE=kmod apt-get install -y falco'
}

fix_rm_usage() {
    sed 's/\brm \([^ ]\)/rm -f \1/g'
}

bash -x <( \
    download_and_customize_script \
  )
