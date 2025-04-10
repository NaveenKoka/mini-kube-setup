terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

resource "null_resource" "install_minikube" {
  provisioner "local-exec" {
    command = <<EOT
      # Install Docker
      sudo apt-get update
      sudo apt-get install -y docker.io
      sudo systemctl enable docker
      sudo systemctl start docker
      sudo usermod -aG docker $USER

      # Install kubectl
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

      # Install Minikube
      curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
      sudo install minikube-linux-amd64 /usr/local/bin/minikube

      # Start Minikube
      minikube start --driver=docker --cpus=4 --memory=8192
    EOT
  }
}
