# Go Microservice Boilerplate 
[![Build Status](https://travis-ci.com/LarsOL/golang-boilerplate-microservice.svg?branch=master)](https://travis-ci.com/LarsOL/golang-boilerplate-microservice)

This is a example repo setting up a simple golang microservice boilerplate

## Endpoints
- Hello World (GET): `/` (Returns hello world and the request you sent it)
- Status (GET): `/status` (Return JSON on service metadata)

## Requirements
- Golang 1.12+

## Build Tools

This project contains a `make.sh` which acts as bootstrap and consistent interface in which both the CI/CD & developers can preform operations on the project. It also standardises the behaviour of multiple different languages, which can be extended in the future using the same infrastructure

Customisation of build infrastructure for this microservice is implemented in the `app.sh`, and this includes the metadata

### Common Commands

 * `./make.sh` will show full usage
 * `./make.sh serve` will run the local environment
    
    App will run in [http://localhost:8080](http://localhost:8080)
    
 * `./make.sh test` will run unit tests locally
 * `./make.sh integration-test|it` will run integration tests locally
 * `./make.sh static-analysis|sa` will run multiple golang static analysis tools
 * `./make.sh publish`

## Future Improvements
 * Currently the tests & local serve are directly using the local golang tooling in order to improve the speed of development. For even more consistent behaviour we could instead package the docker image and run against that, in exchange for a slower build
 * Because canarying / cloud tests are so dependent on the deployment envrioment, they are not implemented here. Please implement what makes sense for your enviroment.
 