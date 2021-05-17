input_users=( "$@" )
declare -a id_users=()
for user in "${input_users[@]}"
        do
                output_json_user_id=`openstack user show -f json $user`
                id_users+=(`echo $output_json_user_id | jq -r '.id'`)
        done
output_list="["
for id in "${id_users[@]}"
        do
                if [ "$id" != "${id_users[-1]}" ]; then
                        output_list="$output_list\"$id\","
                else
                        output_list="$output_list\"$id\""
                fi
        done

output_list="$output_list]"
export TF_VAR_user_id_list="$output_list"