# nodeJS image

[`serafinframework/nodejs`](https://hub.docker.com/r/serafinframework/nodejs/)

A [nodeJS](https://alpinelinux.org/) image, based on [Serain Framework Linux Alpine image](https://hub.docker.com/r/serafinframework/alpine/), with common related tools and a project builder script.
**dev** variants (see tags) include common development tools and features.

## development tags

**dev** tags are available and provide common *nodeJS* development packages (global installation), as well as the parent's image development tools.

Development Linux packages:
- compilation tools
- openssh
- jq

Development ndoeJS packages:
- typescript
- typings
- grunt-cli
- bower
- gulp
- forever
- pm2
- mocha
- istanbul
- newman
- force-dedupe-git-modules
- bunyan
- depcheck 

## Usage

This image expect project files to be available in the directory [/srv](http://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s17.html).
The default command is *npm start*. Therefore, this image is designed to run a project embedding a *package.json* file, that includes a *start* script section, for instance:

```
  "scripts": {
    "start": "forever --minUptime 1000 --spinSleepTime 1000 lib/index.js",
  }
```

### To build the image:
    
`docker build Dockerfile`

### To run the image

`docker run --rm serafinframework/nodejs <command>`

### To open a shell in the running container

`docker exec -ti <container_name> sh`

Containers from the *dev* image tags allow to run a *bash* or even a *zsh* shell (recommended). Just replace *sh* by the desired shell.

### Project development context

To run a container embedding a local project:

`docker run --name <my_project> -v .:/srv -p 80:80 -p 5858:5858 serafinframework/nodejs-dev`

> - port *80* serves HTTP content
> - port *5859* can be mapped to attach a debugger

Optionaly, other volumes can be mounted to ease development:
 - *~/.ssh/id_rsa:/home/node/.ssh/id_rsa:ro*: to share a *git rsa key* (git credentials forwarding)
 - *~/.gitconfig:/home/node/.gitconfig:ro*: to share *git* developer info (user email)
 - *~/.npmrc:/home/node/.npmrc:ro*: to share access to *NPM* private repositories (NPM crentials forwarding)
    
##### *docker-compose.yml* configuration sample

```
version: "2"
services:
    csl:
        image: serafinframework/nodejs-dev
        ports:
            - "80:80"
            - "5858:5859"
        links:
            - memcached
            - dynamodb
        volumes:
            - .:/srv
            - ~/.ssh/id_rsa:/home/node/.ssh/id_rsa:ro
            - ~/.gitconfig:/home/node/.gitconfig:ro
            - ~/.npmrc:/home/node/.npmrc:ro
```

## Commands

### startup.sh
The container entrypoint runs the script *startup.sh*, that attach the debugger, run the container command, and reads optional environment variables to:
- adjust the timezone
- pull the project from a Git bucket

#### Environment variables
- `TIMEZONE` can be used to define a different timezone
- `BUILD` if not null, the project will be fetched and built from a Git bucket, according to these environment variables:
  - `GIT_BUCKET` the git project bucket.
  - `GIT_BRANCH` (optional) *master* by default. Can specify another git branch.
  - `BUILD` (optional) if the value is *dev*, the project will be versioned and embed NPM dev packages.

##### Example
`docker run -ti -v ~/.ssh/id_rsa:/home/node/.ssh/id_rsa -v ~/.npmrc:/home/node/.npmrc -e TIMEZONE='America/Montreal' -e BUILD=1 -e GIT_BUCKET=git@bitbucket.org:serafinframework/myproject.git GIT_BRANCH=test serafinframework/nodejs`

### startup-timezone.sh
The image includes the executable */opt/docker/startup-timezone.sh*, which can be used at runtime to set the container timezone.
The timezone must correspond to the [Linux tzdata timezone names](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones), for instance *America/Montreal*.

### build.sh
The image includes the executable */opt/docker/build.sh*, which can be used at runtime to fetch the project from Git sources.
May need an *id-rsa key* to be shared for the bucket to be accessible.

After fetching the source, a *npm install* command is run.
If the *developer* option is set, the resulting project will be versioned, and the NPM development packages will be deployed.
Otherwise, the project will be a production version.

##### Usage
`/opt/docker/build.sh [-dh] <git bucket> [<git branch>]`