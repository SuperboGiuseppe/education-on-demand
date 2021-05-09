#Export user id
output_json_user_id=`openstack user show -f json $1`
TF_VAR_member_user_id=`echo $output_json_user_id | jq -r '.id'`