#!/bin/bash

basename=$(basename $0)
dirname=$(dirname $0)

VERSION=
declare -a ARGS

while [ ${#} -ne 0 ]; do
    arg=$1
    case $arg in
        --version)
            shift
            if [ ${#} -eq 0 ]; then
                echo "Missing value for $arg" >&2
                exit 1
            fi
            VERSION=$1
            ;;
        --version=*)
            VERSION=${arg/#--version=//}
            ;;
        *)
            ARGS[${#ARGS[@]}]=$1
            ;;
    esac
    shift
done

if [ -z "$VERSION" ]; then
    echo "Version not specified, trying to guess it"
    # Trying to figure the version out
    VERSION=$(ls $dirname/*/$basename | xargs -l dirname | sort -r | head -1)
    if [ -z "$VERSION" ]; then
        echo "Unable to find a product version" >&2
        exit 1
    fi
fi

echo "Using version $(basename $VERSION)"

bash $VERSION/$basename "${ARGS[@]}"
