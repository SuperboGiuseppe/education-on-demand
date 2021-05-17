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


resource "openstack_compute_keypair_v2" "keypair_generation" {
  count=length(var.user_name_list)
  name=var.user_name_list[count.index]
}

resource "openstack_compute_instance_v2" "lod_fe_01" {
  name = "lod_fe_01"
  image_id = "${openstack_images_image_v2.ubuntu_os.id}"
  flavor_id = "2"
  key_pair = "${openstack_compute_keypair_v2.keypair_generation}"
}

