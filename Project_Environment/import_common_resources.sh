#Export "Member" role id from openstack environment
output_json_member_id=`openstack role show -f json member`
TF_VAR_member_role_id=`echo ${output_json_member_id} | jq -r '.id'`

#Export "Admin" role id from openstack environment
output_json_admin_id=`openstack role show -f json admin`
TF_VAR_admin_role_id=`echo ${output_json_admin_id} | jq -r '.id'`

