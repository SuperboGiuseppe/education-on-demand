#Export "linux_on_demand" project id from openstack environment
output_json_project_id=`openstack project show linux_on_demand -f json`
export TF_VAR_project_id=`echo ${output_json_project_id} | jq -r '.id'`

#Export project members list
output_json_member_list=`openstack user list --project ${TF_VAR_project_id} -f json`

declare -a user_id_list=($(echo ${output_json_member_list} | jq '.[] | .ID'))
output_user_id_list="["
for id in "${user_id_list[@]}"
        do
                if [ "$id" != "${user_id_list[-1]}" ]; then
                        output_list="$output_user_id_list\"$id\","
                else
                        output_list="$output_user_id_list\"$id\""
                fi
        done
output_user_id_list="$output_user_id_list]"
export TF_VAR_user_id_list="$output_user_id_list"

declare -a user_name_list=($(echo ${output_json_member_list} | jq '.[] | .Name'))
output_user_name_list="["
for name in "${user_name_list[@]}"
        do
                if [ "$name" != "${user_name_list[-1]}" ]; then
                        output_list="$output_user_name_list\"$name\","
                else
                        output_list="$output_user_name_list\"$name\""
                fi
        done
output_user_name_list="$output_user_name_list]"
export TF_VAR_user_name_list="$output_user_name_list"


#Export subnet pool id
output_json_subnet_pool=`openstack subnet pool show shared-default-subnetpool-v4 -f json`
export TF_VAR_subnet_pool_id=`echo ${output_json_subnet_pool} | jq -r '.id'`

#Export public network id
output_json_public_network=`openstack network show public -f json`
export TF_VAR_public_network_id=`echo ${output_json_public_network} | jq -r '.id'`




