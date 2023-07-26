#!/usr/bin/env bash
set -ex
function read_machines() {
    ip_file=instance_ip.out
    name_file=instance_name.out
    zone_file=instance_ip.out
}

## provide filename in bucket
## s1: bucket name s2: file name s3: local directory
download_file() {
	for retry in 0 1 2
	do
		if [[ $retry -gt 2 ]];then
			break
		fi
		gsutil cp "$1/$2" "$3"
		if [[ ! -f "$2" ]];then
			echo NO "$2" found, retry
		else
            echo "$2" dowloaded
			break
		fi
        sleep 5
	done
}
upload_file() {
	gsutil cp  "$1" "$2"
}

function get_testnet_ver() {
    local ret
    for retry in 0 1 2
    do
        if [[ $retry -gt 1 ]];then
            break
        fi
        ret=$(curl $ENDPOINT -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getVersion"}
        ' | jq '.result."solana-core"' | sed 's/\"//g') || true
        if [[ $ret =~ [0-9]+.[0-9]+.[0-9]+ ]];then
            break
        fi
        sleep 3
    done
    if [[ ! $ret =~ ^[0-9]+.[0-9]+.[0-9]+ ]];then
        echo master
    else
        #adding a v because the branch has a v
       echo v$ret
    fi
}

# given time $1 and get after $2 seconds
get_time_after() {
	outcom_in_sec=$(echo $1 + $2 | bc)
    echo $outcom_in_sec
}

# given time $1 and get before $2 seconds
get_time_before() {
	outcom_in_sec=$(echo $1 - $2 | bc) 
    echo $outcom_in_sec
}

# extract_time: extract number and unit from string like 10s, 10m, 10h
# argv1: string like 10s, 10m, 10h
# return: use $duration_in_seconds or return value $?
function extract_time_in_sec {
    if [[ $1 =~ ^([0-9]+)([smh])$ ]]; then
        number="${BASH_REMATCH[1]}"
        unit="${BASH_REMATCH[2]}"

        case "$unit" in
            s)
                duration_in_seconds="$number"
                ;;
            m)
                duration_in_seconds=$((number * 60))
                ;;
            h)
                duration_in_seconds=$((number * 3600))
                ;;
            *)
            duration_in_seconds=0
                ;;
        esac
        echo "$duration_in_seconds"
    fi
}

