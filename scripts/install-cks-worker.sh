#!/bin/bash
set -ex
ARCH=$(uname -m)

awk_shebang='NR==1 {sub(/^#!\/bin\/sh/, "#!/bin/bash")}'
awk_arch=""
if [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
  awk_arch='{gsub(/amd64/, "arm64")}'
fi

bash <( \
  curl --silent "https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/${INSTALL_SCRIPT}/install_worker.sh" \
  | awk "$awk_shebang $awk_arch 1"
)
