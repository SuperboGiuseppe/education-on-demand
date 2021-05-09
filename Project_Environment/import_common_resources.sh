#Export "Member" role id from openstack environment
output_json_member_id=`openstack role show -f json member`
TF_VAR_member_role_id=`echo ${output_json_member_id} | jq -r '.id'`


