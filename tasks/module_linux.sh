#!/bin/bash

config_file=${PT_config_file}
status=${PT_status}
module=${PT_module}
interleave="${PT_interleave:-true}"
failonfail="${PT_failonfail:-true}"
error_code=255

command="metricbeat -c $config_file modules $status $module"

function validate_boolean()
{
    value=$1
    if [[ $value == "true" || $value == "false" ]]; then
        return 0
    else
        return 1
    fi
}

function error_json()
{
    message=$1
    exit_code=$2
    error_payload=$(cat <<EOF
{
	"_error": {
		"msg": "Exec task unsuccessful due to ${message}.",
		"kind": "puppetlabs.tasks/task-error",
		"details": {
			"exitcode": ${exit_code}
		}
	}
}
EOF
)
    echo $error_payload
}

# Validate inputs
if [ "$status" = "" ]; then
    error_json "empty status" ${error_code}
    exit ${error_code}
fi

validate_boolean ${interleave}
interleave_valid=$?
validate_boolean ${failonfail}
failonfail_valid=$?
if [[ ${interleave_valid} != "0" || ${failonfail_valid} != "0" ]]; then
	error_json "invalid input parameters" ${error_code}
	exit ${error_code}
fi

# Run command, redirecting stderr if requested
if [ "$interleave" == "true" ]; then
    output_from_command=$(eval ${command} 2>&1)
else
    output_from_command=$(eval ${command})
fi

status_from_command=$?
# Determine what the exit code should be.
if [[ "$failonfail" == "true" && "$status_from_command" != "0" ]]; then
    exit_code=${error_code}
else
    exit_code=0
fi

# Produce output to stdout
if [ "$status_from_command" == "0" ]; then
    echo "${output_from_command}"
    echo "${command}"
else
    error_json "${output_from_command}" ${exit_code}
fi


exit $exit_code