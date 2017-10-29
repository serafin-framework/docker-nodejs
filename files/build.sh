#!/bin/sh

USAGE="Deploys NPM project sources from a Git repository.

Usage: $(basename "$0") [hd] <Git bucket> [branch]
Options:
    Git bucket:     URL of the Git bucket
    branch:         Git branch, 'master' if not specified

    -h              display the help
    -d              development deployment
"

BUILD='prod'

while getopts "dh" option
do
    case $option in
        h)
            echo "$USAGE"
            exit
            ;;
        d)
            BUILD='dev'
            ;;
        \?)
            echo "$OPTARG : invalid option"
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))
GIT_BUCKET=$1
GIT_BRANCH=$2

if [ -z $GIT_BUCKET ]; then
    2>&1 echo "$USAGE"
    exit
fi

### Build from Git bucket
if [ ! -e /root/.ssh/id_rsa ]; then
    2>&1 echo "'~/.ssh/id_rsa' Bitbucket SSH key not found. SSH git repositories need one"
fi

if [ -z $GIT_BUCKET ]; then
    2>&1 echo "GIT_BUCKET not specified"
    exit
fi

if [ -z $GIT_BRANCH ]; then
    GIT_BRANCH='master'
fi

echo "* Repository initialization from '$GIT_BUCKET#$GIT_BRANCH'"

if [ $(find . -type d -name '.' -empty|wc -l) -ne 1 ]; then
    echo "* Directory `pwd` not empty, storing content into '.backup'"
    mkdir -p .backup
    find * .* -maxdepth 0 -not -name '.' -not -name '..' -not -path '.backup' -exec mv '{}' .backup \;
fi

git init
git remote add origin $GIT_BUCKET

echo "* GIT pull from branch '$GIT_BRANCH'"
git pull -q origin $GIT_BRANCH

if [ -e "package.json" ]; then
    if [ $BUILD = "prod" ]; then
        echo "* Production installation"
        npm install --production
        find . -type d -name .git -exec rm -Rf {} +
    elif [ $BUILD = "dev" ]; then
        echo "* Development installation"
        npm install
        #typings -g install && typings install
    fi
fi