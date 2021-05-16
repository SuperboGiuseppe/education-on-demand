#Export "linux_on_demand" project id from openstack environment
output_json_project_id=`openstack project show linux_on_demand -f json`
TF_VAR_project_id=`echo ${output_json_project_id} | jq -r '.id'`

#Export project members list
output_json_member_list=`openstack user list --project ${project_id} -f json`
declare -a TF_VAR_user_id_list=($(echo ${output_json_member_list} | jq '.[] | .ID'))
declare -a TF_VAR_user_name_list=($(echo ${output_json_member_list} | jq '.[] | .Name'))

#Export subnet pool id
output_json_subnet_pool=`openstack subnet pool show shared-default-subnetpool-v4 -f json`
TF_VAR_subnet_pool_id=`echo ${output_json_subnet_pool} | jq -r '.id'`

#Export public network id
output_json_public_network=`openstack network show public -f json`
TF_VAR_public_network_id=`echo ${output_json_public_network} | jq -r '.id'`


