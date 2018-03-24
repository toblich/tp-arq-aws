locals {
  installer_urls = {
    datadog_agent = "https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh"
    nvm           = "https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh"
  }

  #   connection = {
  #     type        = "ssh"
  #     user        = "ec2-user"
  #     private_key = "${file(var.private_key_location)}"
  #   }
}

resource "aws_instance" "node" {
  ami                    = "ami-1853ac65"
  instance_type          = "t2.micro"
  key_name               = "${var.key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.apps.id}"]

  tags {
    Name = "tp_arqui_node"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.node.public_ip} > node_ip_address.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ------- Download nvm and install it -------",
      "curl -o- ${local.installer_urls["nvm"]} | bash",
      "echo ------- Load nvm -------",
      ". ~/.nvm/nvm.sh",
      "echo ------- Install node -------",
      "nvm install 8.9",
      "echo ------- Log node and npm versions -------",
      "npm version",
      "echo ------- Create application directory: ${var.root} -------",
      "mkdir ${var.root}",
      "echo ------- Install Datadog Agent -------",
      "export DD_API_KEY=${var.datadog_key}",
      "export DD_PROCESS_AGENT_ENABLED=true",
      "curl -L -o- ${local.installer_urls["datadog_agent"]} | bash",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.private_key_location)}"
    }
  }

  provisioner "file" {
    source      = "node/app.js"
    destination = "${var.root}/app.js"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.private_key_location)}"
    }
  }

  provisioner "file" {
    source      = "node/package.json"
    destination = "${var.root}/package.json"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.private_key_location)}"
    }
  }

  provisioner "file" {
    source      = "node/package-lock.json"
    destination = "${var.root}/package-lock.json"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.private_key_location)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "echo ------- Move into application directory: ${var.root} -------",
      "cd ${var.root}",
      "echo ------- Install dependencies -------",
      "npm install",
      "echo \n************************************\n",
      "echo ------- Starting app in background -------",
      "node . &",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.private_key_location)}"
    }
  }
}
