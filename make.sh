#!/bin/bash

# The purpose of this make script is to bootstrap projects
# and provide a consistent way for both the CI and developers to do operations on the project,
# regardless of language or technology.

# This is the "generic" portion of the system (think gradlew) and should not be modified,
# any customisation for a microservice should be done in the corresponding app.sh.

# It provides a common interface that is defined in CORE_COMMANDS,
# to facilitate customisation you can implement a pre_<command> or post_<command> in your app.sh

# Note: If any common tasks are done with custom commands, rather than through make.sh. That is a candidate to be implemented

# DO NOT MODIFY - This is from the boilerplate repo.
# If changes are needed, update there, then use the `./make.sh update-build-tools` to bring in the changes

# Fail on any error by default
set -e

# These commands MUST be implemented.
readonly CORE_COMMANDS=(usage generate test integration-test static-analysis deploy serve update-build-tools publish)
readonly WORKSPACE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Bring in common helper functions
source ${WORKSPACE}/build-tools/utils.sh
pushd ${WORKSPACE} > /dev/null
defer 'echo Restore directory && popd > /dev/null'

if [ -z "$CI" ]; then
    echo "Running locally"
else
    echo "Running on CI"
fi


###############################################################################
# EXECUTION
###############################################################################

# Consume the first argument, or default to 'usage' as command
RAWCOMMAND="usage"
if [ "$#" -ge 1 ]; then
    RAWCOMMAND=$1
    shift
fi
readonly RAWCOMMAND
readonly ARGS=($@)

# actual function will use underscore instead of hyphen
readonly COMMAND=${RAWCOMMAND//-/_}

echo "
-----------------------------------------------------
 * workspace: ${WORKSPACE}
 * command:   ${RAWCOMMAND}
 * arguments: ${ARGS[*]}
-----------------------------------------------------
"

# Configuration from app.sh
source ${WORKSPACE}/app.sh
case ${projectType} in
    goService)
        # This is a place to hook different behaviour based on golang version.
        case ${goRuntime} in
            1.12)
                source ${WORKSPACE}/build-tools/go_1_12.sh
                ;;
            *)
                echo "WARNING: Please specify a goRuntime; assuming Go 1.12"
                source ${WORKSPACE}/build-tools/go_1_12.sh
                ;;
        esac
        ;;
    *)
        echo "Don't know how to handle projectType ${projectType}"
        exit 1
        ;;
esac

if ! core_commands_implemented; then
    echo "All core commands must have implementations"
    exit 1
fi

if ! function_exists ${COMMAND}; then
    echo "ERROR: Unknown command '${COMMAND}'"
    usage
    exit 1
elif [[ "${COMMAND}" == "usage" ]]; then
    # Special case for usage, we don't wrap it with pre_ and _post hooks
    usage
    exit 0
else
    exec_wrapped_function ${COMMAND} ${ARGS[*]}
    exit $?
fi
