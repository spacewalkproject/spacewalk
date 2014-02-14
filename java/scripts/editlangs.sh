#!/bin/bash
# Just a small script to do couple of common tasks with translations.
# Commands expect XML files to be formatted using xmllint. Such state
# can be achieved by command `format`. Available commands:
#
#   * format
#     Formats all translation XML files
#   * del <key>
#     Deletes all translation units which have id matching
#     `<key>` pattern.
#   * sed <key> <expression>
#     Transforms with sed `<expression>` all translation units
#     which have id matching `<key>`
#
# PS: Source is often be better than any other documentation ;-).

RESOURCES_BASE="java/code/src/com/redhat/rhn/frontend/strings/jsp"
GIT_ROOT="$( git -c alias.a='!pwd' a )"

function fail() {
    echo "$@"
    exit 1
}

function run_sed() {
    find "$RESOURCES_BASE" -name '*.xml' -print0 \
    | xargs -0 --no-run-if-empty -n 1 \
        sed -i '/^[[:space:]]*<trans-unit id="'"$1"'">$/,/^[[:space:]]*<\/trans-unit>$/{'"$2"'}'
}

function run_del() {
    run_sed "$1" 'd'
}

function run_format() {
    find "$RESOURCES_BASE" -name '*.xml' -print0 \
    | xargs -0 --no-run-if-empty -n 1 \
        bash -c 'tmp=$( mktemp ); xmllint --format "$1" > $tmp; mv $tmp "$1"' --
}

function main() {
    if ! git status >&/dev/null; then
        fail 'Not in git repo'
    fi
    cd "$GIT_ROOT"
    if ! [ -d $RESOURCES_BASE ]; then
        fail "Can't find $GIT_ROOT/$RESOURCES_BASE"
    fi
    if [[ $# -lt 1 ]]; then
        fail 'Expected command'
    fi
    local run
    local cmd=$1
    shift
    case "$cmd" in
        sed)
            run=run_$cmd
            if [[ $# -ne 2 ]]; then
                fail "Have to be: $cmd <key> <expression>"
            fi
            ;;
        del)
            run=run_$cmd
            if [[ $# -ne 1 ]]; then
                fail "Have to be: $cmd <key>"
            fi
            ;;
        format)
            run=run_$cmd
            if [[ $# -ne 0 ]]; then
                fail "Command $cmd takes no arguments"
            fi
            ;;
        *)
            fail "Invalid command: $1"
            ;;
    esac
    "$run" "$@"
}

main "$@"
