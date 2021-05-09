resource "openstack_identity_project_v3" "term_project" {
    name = var.project_name
    description = "Openstack project for the Fog and Cloud Computing Term project
}

resource "openstack_identity_user_v3" "eval_user" {
    default_project_id = "${openstack_identity_project_v3.term_project.id}"
    name = "eval"
    description = "Evaluation user"

    username = var.username
    password = var.password
}

resource "openstack_identity_role_assignment_v3" "project_membership_fixed" {
  user_id    = "${openstack_identity_user_v3.eval_user.id}"
  project_id = "${openstack_identity_project_v3.term_project.id}"
  role_id    = var.member_role_id
}

resource "openstack_identity_role_assignment_v3" "project_membership_dynamic" {
  count=length(var.user_id_list)
  user_id = var.user_id_list[count.index]
  project_id = "${openstack_identity_project_v3.term_project.id}"
  role_id    = var.member_role_id
}