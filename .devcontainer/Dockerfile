FROM ubuntu:noble
RUN <<EOF
apt-get update
apt-get install --yes sudo
echo ubuntu ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/ubuntu
EOF
USER ubuntu
