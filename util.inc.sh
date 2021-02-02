#/bin/true # do not call directly

function log() {
    local "$@"
    echo "LOG: ${msg}"
}


function die() {
    local "$@"
    log msg="$msg"
    log msg="ABORTING with RC=${rc}"
    exit "$rc"
}

