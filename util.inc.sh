#/bin/true # do not call directly

function log() {
    local "$@"
    echo -e "\e[1mLOG:\e[0m ${msg}"
}


function die() {
    local "$@"
    log msg="$msg"
    log msg="ABORTING with RC=${rc}"
    exit "$rc"
}

