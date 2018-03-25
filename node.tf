locals {
  installer_urls = {
    nvm = "https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh"
  }
}

resource "aws_instance" "node" {
  ami                    = "${var.ami_id}"
  instance_type          = "t2.micro"
  key_name               = "${var.key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.apps.id}"]

  tags {
    Name = "tp_arqui_node"
  }

  # Store the resulting IP
  provisioner "local-exec" {
    command = "echo ${aws_instance.node.public_ip} > node/ip"
  }

  # Environment setup
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
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.private_key_location)}"
    }
  }

  # Upload installer script
  provisioner "file" {
    source      = "install_datadog.sh"
    destination = "~/install_datadog.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.private_key_location)}"
    }
  }

  # Execute installer script
  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/install_datadog.sh",
      "~/install_datadog.sh ${var.datadog_key}",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.private_key_location)}"
    }
  }

  # Upload app
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

  # Install app deps and run
  provisioner "remote-exec" {
    inline = [
      "echo ------- Move into application directory: ${var.root} -------",
      "cd ${var.root}",
      "echo ------- Install dependencies -------",
      "npm install",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.private_key_location)}"
    }
  }
}
