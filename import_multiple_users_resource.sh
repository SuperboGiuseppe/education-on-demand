users_test=( "$@" )
declare -a output_arr=()
for user in "${users[@]}"
        do
                output_json_user_id=`openstack user show -f json $user`
                output_arr+=(`echo $output_json_user_id | jq -r '.id'`)
        done