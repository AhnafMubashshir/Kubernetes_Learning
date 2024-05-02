sudo swapoff -a

#Operating system Configuration
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

#Sysctl params configuration
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
nte.ipv4.ip_forward = 1
EOF

#apply sysctl params without reboot
sudo sysctl --system


#install contaierd
sudo apt-get install -y containerd

#creating containerd configuration file
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

#changing systemdGgroup to true
sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /ect/containerrd/config.toml

# restart containerd to apply the new configuration
sudo systemctl restart containerd

# Installing Kubernetes packages
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

#Adding kubernetes apt repo
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

#updating pkg lists & using apt-cache policy to inspect versions vailable in the repo
sudo apt-get update
apt-cache policy kubelet | head -n 20

#Installing kubelet exact version
VERSION=1.29.1-1.1
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
sudo apt-mark hold kubelet kubeadm kubectl containerd


#Checking status
sudo systemctl status kubelet.service
sudo sytemctl status containerd.service