#!/bin/bash

# This is the file in which the microservice customises the operations e.g setting ENV, running custom setup, cleanup

# API for hooks
# $1: deployTarget, or '' for local

# Returning exit code != 0 will stop script

projectType='goService'
goRuntime="1.12"
serviceName="exampleGoService"

version="1.0"
description="Example Boilerplate Microservice"


pre_test(){
    echo "Example of customising the build-tools on a application level"
    echo "You could run custom test setup commands here"
}


