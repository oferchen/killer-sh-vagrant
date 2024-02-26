#!/bin/bash
set -ex
ARCH=$(uname -m)

awk_shebang='NR==1 {sub(/^#!\/bin\/sh/, "#!/bin/bash")}'
awk_arch=""
if [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
  awk_arch='{gsub(/amd64/, "arm64")}'
fi

awk_kubeadm_init='/kubeadm init/ {
  if (!match($0, /--apiserver-advertise-address=/)) {
    $0 = $0 " --apiserver-advertise-address=192.168.5.10"
  } else {
    gsub(/--apiserver-advertise-address=[^ ]+/, "--apiserver-advertise-address=192.168.5.10")
  }
}'

bash -x <( \
  curl -s "https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/${INSTALL_SCRIPT}/install_master.sh" \
  | awk "$awk_shebang $awk_arch $awk_kubeadm_init 1"
)
