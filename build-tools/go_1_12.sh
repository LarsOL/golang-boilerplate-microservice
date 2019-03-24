#!/usr/bin/env bash

readonly TEST_RESULTS_DIR=${WORKSPACE}/test-results
readonly MAIN_DIR=${WORKSPACE}/cmd
echo "app version: $version"

###############################################################################
# CORE COMMANDS
###############################################################################

usage() {
  echo "Usage: ./make.sh <command> [arguments]

Commands:
usage:               Show this usage information.
generate:            Run Generate tools.
test:                Run unit tests. Arguments:
  - testpattern:   (optional) partial match of test function name(s)
integration-test/it: Run integration tests. Arguments:
  - testpattern: (optional) partial match of test function name(s)
static-analysis/sa:  Run linting.
deploy:              Deploys project to <platform>. Arguments:
  - deployTarget:   (required) Where to deploy to.
serve:               Serve the application locally.
"
}

generate() {
    return 0
}

test() {
    local readonly testname=$1
    local readonly coverresults_dir=${WORKSPACE}/coverage-results
    local readonly unit_test_out=${WORKSPACE}/unitTestOut.txt

    setup_env
    exec_wrapped_function generate
    run_format

    mkdir -p ${coverresults_dir}
    rm -rf ${coverresults_dir}/*

    echo "Running unit tests..."

    go test -v -covermode=atomic --run=$1 -coverprofile=${coverresults_dir}/cover.out ./... 2>&1 | tee ${unit_test_out}
    local readonly test_exit_code=${PIPESTATUS[0]}
    defer "echo Delete unit test output && rm -v ${unit_test_out}"

    echo "* unit tests finished"
    defer "echo Tests finished with code: ${test_exit_code}"
    go tool cover -html=${coverresults_dir}/cover.out -o ${coverresults_dir}/cover.html

#    echo "* Writing report"
#    mkdir -p ${TEST_RESULTS_DIR}
#    cat ${unit_test_out} | go-junit-report > ${TEST_RESULTS_DIR}/unit-report.xml

    return "${test_exit_code}"
}

integration_test() {
    local readonly integration_test_dir=${WORKSPACE}/integration_test

    if [ ! -d ${integration_test_dir} ]; then
        echo "No Integration Tests found"
        return 0
    fi

    setup_env
    exec_wrapped_function generate

    echo "* Starting a service..."

    run &

     defer 'echo Killing service && kill -9 $(lsof -i :8080 -t)'

    # upcheck
    upcheck -timeout 15 -urlSource - << ENDURLS
        http://localhost:8080/status
ENDURLS
    local readonly upcheck_result=$?
    if [ ${upcheck_result} -ne 0 ]; then
        echo "* Service failed to start"
        return ${upcheck_result}
    fi

    echo "* Service started"
    echo "Running integration tests. $1"

    local readonly integration_test_out=${WORKSPACE}/integrationTestOut.txt

    pushd ${integration_test_dir} > /dev/null
    go test --run=$1 -v ./... 2>&1 | tee ${integration_test_out}
    local readonly test_exit_code=${PIPESTATUS[0]}
    defer "echo Delete integration test output && rm -v ${integration_test_out}"
    popd > /dev/null

    echo "* Integration tests finished"
    defer "echo Integration tests finished with code: ${test_exit_code}"
    echo "* Writing report"

#    mkdir -p ${TEST_RESULTS_DIR}
#    cat ${integration_test_out} | go-junit-report > ${TEST_RESULTS_DIR}/integration-report.xml
        
    return ${test_exit_code}
}

# Alias for integration-test
it() {
    integration_test $@
}

deploy() {
   echo "This is where we would confirm the environment is ready to deploy and start triggering migration"
   echo "If we have canarying i.e Spinnaker and Kayenta this is where we would trigger"
   echo "Also trigger any shakeout/ cloud or end to end tests that run against the acctual deployment/staging env"
}

static_analysis() {
  local analysis_results_dir=${WORKSPACE}/analysis-results
  curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s latest
  mkdir -p ${analysis_results_dir}
  rm -rf ${analysis_results_dir}/*
  ./bin/golangci-lint run ./...
  if [ "$?" -ne 0 ]; then
        echo "static analysis failed"
        return 1
  fi
}

# Alias for static-analysis
sa () {
    static_analysis $@
}

publish() {
   echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
   echo "Embedding version: ${version} description: ${description}"
   docker build -t larslawoko/example-go-microservice:latest --build-arg META_DESC="${description}" --build-arg META_VERSION="${version}" .
   docker push larslawoko/example-go-microservice:latest
}

serve() {
    setup_env
    exec_wrapped_function generate
    run
}

run() {
 go run ${MAIN_DIR}/main.go
}

###############################################################################
# CUSTOM COMMANDS
###############################################################################

check_deps() {
    # operating system
    echo "OS: "`uname -a`

    # go version check
    go version
    if [ "$?" -gt 0 ]; then
        echo "go sdk is required"
        return 1
    fi

    echo "build version: ${BUILD_VERS}"
}

get_tools() {
# Use old gopath to ensure binaries are put in PATH
  GO111MODULE=off go get golang.org/x/tools/cmd/goimports
  GO111MODULE=off go get bitbucket.org/aprilayres/upcheck
}


setup_env() {
  echo "Running check and get deps..."
  check_deps
  get_tools
}

run_format() {
    echo "* Running goimports..."
    find ${WORKSPACE}/ -name "*.go" -exec goimports -w {} \;

    local commentsToFind="Deprecated|FIXME|TODO"
    echo "* Scanning comments (${commentsToFind})..."
    echo
    find ${WORKSPACE}/ -name "*.go" | xargs egrep --colour=always -n -A 2 -i "${commentsToFind}" | awk '{$1=$1;print}'
    exitCode=$?

    echo "-----------------------------------------------------"
    if [ ${exitCode} -gt 1 ]; then
        return $?
    elif [ ${exitCode} -eq 1 ]; then
        echo "- Nothing found."
    else
        echo "- Some comments found."
        echo "- Please have a look at them before pushing your changes"
    fi
    echo "-----------------------------------------------------"
}

