terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Step 1: Install Docker
resource "null_resource" "install_docker" {
  provisioner "local-exec" {
    command = <<EOT
      sudo apt-get update
      sudo apt-get install -y docker.io
      sudo systemctl enable docker
      sudo systemctl start docker
    EOT
  }
}

# Step 2: Wait for Docker to be ready
resource "null_resource" "wait_for_docker" {
  depends_on = [null_resource.install_docker]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for Docker to be ready..."
      until sudo docker info > /dev/null 2>&1; do
        sleep 2
      done
      echo "Docker is ready!"
    EOT
  }
}

# Step 3: Install kubectl and Minikube
resource "null_resource" "install_kubectl_minikube" {
  depends_on = [null_resource.wait_for_docker]

  provisioner "local-exec" {
    command = <<EOT
      # Install kubectl
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

      # Install Minikube
      curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
      sudo install minikube-linux-amd64 /usr/local/bin/minikube
    EOT
  }
}

# Step 4: Start Minikube
resource "null_resource" "start_minikube" {
  depends_on = [null_resource.install_kubectl_minikube]

  provisioner "local-exec" {
    command = "minikube start --driver=docker --cpus=4 --memory=8192"
  }
}
