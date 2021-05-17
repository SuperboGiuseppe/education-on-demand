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

resource "openstack_compute_secgroup_v2 "http_https_security_group" {
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

resource "openstack_compute_keypair_v2" "keypair_generation" {
  name="${var.short_project_name}_key"
}

resource "openstack_networking_floatingip_v2" "lod-fe-floatingip" {
  pool = "public"
}

resource "openstack_compute_instance_v2" "lod_fe_01" {
  name = "lod_fe_01"
  image_id = "${openstack_images_image_v2.ubuntu_os.id}"
  flavor_id = "2"
  key_pair = "${openstack_compute_keypair_v2.keypair_generation}"
  security_groups = ["${openstack_compute_secgroup_v2.http_https_security_group}", "${openstack_compute_secgroup_v2.ssh_security_group}"]

  network {
    name = "${openstack_networking_network_v2.private_network.name}"
  }
}

resource "opesntack_compute_floatingip_associate_v2" "lod-fe-floatingip-association" {
  floating_ip = "${openstack_networking_floatingip_v2.lod_fe_floatingip.address}"
  instance_id = "${openstack_compute_instance_v2.lod_fe_01.id}"
}



