#!/usr/bin/env bash

###############################################################################
# GENERAL PURPOSE FUNCTIONS
###############################################################################

# This function checks that all the core commands have been implemented
core_commands_implemented() {
    # Assume all implemented to start with
    local result=0
    for c in ${CORE_COMMANDS[*]}; do
        if ! function_exists ${c//-/_}; then
            echo "Missing core function: ${c//-/_}"
            result=1
        fi
    done
    return ${result}
}

_DEFERSTR="echo Running deferred statements"
# A rough approximation to Golang's defer, this function will run command[s] on termination of the process
defer() {
  # Append command, removing any trailing semicolons
  _DEFERSTR="${_DEFERSTR%;}; ${@%;};"
  trap "{ ${_DEFERSTR} }" EXIT
}

function_exists() {
    declare -f -F $1 > /dev/null
    return $?
}

# Executes a function including any pre_ and post_ hooks
exec_wrapped_function() {
    local readonly fn=${1}
    shift
    local args=${@}

    if function_exists pre_${fn}; then
        exec_function pre_${fn} ${args}
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi

    exec_function ${fn} ${args}
    if [ $? -ne 0 ]; then
        return 1
    fi

    if function_exists post_${fn}; then
        exec_function post_${fn} ${args}
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi
}

# Executes a function, logging the function itself and any arguments
exec_function() {
    local readonly fn=$1
    shift
    local readonly args=$@

    echo "Running [${fn}] with args [${args}]"
    ${fn} ${args}
    local readonly returnCode=$?
    echo "Finished running [${fn}]"

    return ${returnCode}
}

# This would provide a way to update the make.sh and build-tools, from the source of truth
update_build_tools() {
    echo "This would run a self-updater"
}