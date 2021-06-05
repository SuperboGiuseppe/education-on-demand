terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

resource "openstack_images_image_v2" "ubuntu_os" {
  name = "Ubuntu18.04"
  image_source_url = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
  container_format = "bare"
  disk_format = "qcow2"

  properties = {
    key = "value"
  }
}

resource "openstack_networking_network_v2" "private_network" {
  name = "${var.short_project_name}_private_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_subnet" {
  name = "${var.short_project_name}_private_network_subnet_1"
  network_id = "${openstack_networking_network_v2.private_network.id}"
  prefix_length = 24
  subnetpool_id = "${var.subnet_pool_id}"
  ip_version = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

resource "openstack_networking_router_v2" "lod_router" {
  name = "${var.short_project_name}_router_1"
  external_network_id = "${var.public_network_id}"
}

resource "openstack_networking_router_interface_v2" "lod_router_interface" {
  router_id = "${openstack_networking_router_v2.lod_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.private_subnet.id}"
}

resource "openstack_compute_secgroup_v2" "ssh_security_group" {
  name = "ssh_security_group"
  description = "Enable to access the instance from outside via SSH connection (Port 22)"

  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "http_https_security_group" {
  name = "http_https_security_group"
  description = "Enable to access the instance from outside via HTTP/HTTPS connection (Port 80/443)"

  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }

  rule {
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}


resource "openstack_compute_secgroup_v2" "ttyd_security_group" {
  name = "ttyd_security_group"
  description = "Enable to access the instance from outside via ttyd default port (Port 7681)"

  rule {
    from_port = 7681
    to_port = 7681
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }

}

resource "openstack_compute_secgroup_v2" "db_security_group" {
  name = "db_security_group"
  description = "Enable to access the instance from outside via Mysql default port (Port 3306)"

  rule {
    from_port = 3306
    to_port = 3306
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }

}

resource "openstack_compute_keypair_v2" "keypair_frontend" {
  name="${var.short_project_name}_fe_key"
}

resource "openstack_compute_keypair_v2" "keypair_backend" {
  name="${var.short_project_name}_be_key"
}

resource "openstack_networking_floatingip_v2" "lod_fe_floatingip" {
  pool = "public"
}



data "cloudinit_config" "user_data_be" {
  gzip = false
  base64_encode = false
  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      users = [
        {
          name = "eval"
          primary_group = "eval"
          groups = "sudo"
          shell = "/bin/bash"
          sudo = ["ALL=(ALL) NOPASSWD:ALL"]
          ssh-authorized-keys = ["${openstack_compute_keypair_v2.keypair_backend.public_key}"]
        }
      ],
      write_files = [
        {
          content = file("./provisioning_script_backend.sh")
          path = "/home/ubuntu/provisioning_script_backend.sh"
          permissions = "0555"
        }, 
        {
          content = file("./ttyd_deployment.yaml")
          path = "/home/eval/ttyd_deployment.yaml"
        }
      ],
      runcmd = [
        ["bash", "/home/ubuntu/provisioning_script_backend.sh", "${var.users_db_password}"]
      ]
    })
  }
}


resource "openstack_compute_instance_v2" "lod_be_01" {
  name = "lod_be_01"
  image_id = "${openstack_images_image_v2.ubuntu_os.id}"
  flavor_id = "3"
  key_pair = "${openstack_compute_keypair_v2.keypair_backend.name}"
  security_groups = ["${openstack_compute_secgroup_v2.db_security_group.name}", "${openstack_compute_secgroup_v2.ssh_security_group.name}"]

  network {
    name = "${openstack_networking_network_v2.private_network.name}"
  }

  user_data = "${data.cloudinit_config.user_data_be.rendered}"
}

data "cloudinit_config" "user_data_fe" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      users = [
        {
          name = "eval"
          primary_group = "eval"
          groups = "sudo"
          shell = "/bin/bash"
          sudo = ["ALL=(ALL) NOPASSWD:ALL"]
          ssh-authorized-keys = ["${openstack_compute_keypair_v2.keypair_frontend.public_key}"]
        }
      ],
      write_files = [
        {
          content = "${openstack_compute_keypair_v2.keypair_backend.private_key}"
          path = "/home/ubuntu/bastion_host_key/bastion_host.pem"
          permissions = "0600"
        },
        {
          content = "${openstack_compute_keypair_v2.keypair_backend.public_key}"
          path = "/home/ubuntu/bastion_host_key/bastion_host.cert"
        },
        {
          content = "${openstack_compute_keypair_v2.keypair_backend.private_key}"
          path = "/home/eval/bastion_host_key/bastion_host.pem"
          permissions = "0600"
        },
        {
          content = "${openstack_compute_keypair_v2.keypair_backend.public_key}"
          path = "/home/eval/bastion_host_key/bastion_host.cert"
        },
        {
          content = file("./provisioning_script_frontend.sh")
          path = "/home/ubuntu/provisioning_script_frontend.sh"
          permissions = "0555"
        } 
      ],
      runcmd = [
        ["bash", "/home/ubuntu/provisioning_script_frontend.sh", "${var.users_db_password}", "${openstack_compute_instance_v2.lod_be_01.access_ip_v4}"]
      ]
    })
  }
}

resource "openstack_compute_instance_v2" "lod_fe_01" {
  name = "lod_fe_01"
  image_id = "${openstack_images_image_v2.ubuntu_os.id}"
  flavor_id = "2"
  key_pair = "${openstack_compute_keypair_v2.keypair_frontend.name}"
  security_groups = ["${openstack_compute_secgroup_v2.http_https_security_group.name}", "${openstack_compute_secgroup_v2.ssh_security_group.name}"]

  network {
    name = "${openstack_networking_network_v2.private_network.name}"
  }

  user_data = "${data.cloudinit_config.user_data_fe.rendered}"
}

resource "openstack_compute_floatingip_associate_v2" "lod_fe_floatingip_association" {
  floating_ip = "${openstack_networking_floatingip_v2.lod_fe_floatingip.address}"
  instance_id = "${openstack_compute_instance_v2.lod_fe_01.id}"
}

resource "local_file" "private_key_file" {
  content = "${openstack_compute_keypair_v2.keypair_frontend.private_key}"
  filename = "generated_key_pair/${var.project_name}/${var.short_project_name}_key.pem"
  file_permission = "0400"
}

resource "local_file" "public_key_file" {
  content = "${openstack_compute_keypair_v2.keypair_frontend.public_key}"
  filename = "generated_key_pair/${var.project_name}/${var.short_project_name}_key.cert"
}





