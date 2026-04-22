#!/usr/bin/env bash
# Shared helpers for build-and-push scripts.
# Expected globals in caller after init:
#   registry, image, tag

set -euo pipefail

build_default_tag() {
    local commit
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        commit="$(git rev-parse --short HEAD)"
    else
        commit="local"
    fi
    date +%Y-%m-%d."${commit}"
}

init_build_args() {
    local default_registry="$1"
    local default_image="$2"

    registry="$default_registry"
    image="$default_image"
    tag="$(build_default_tag)"
}

print_build_usage() {
    local script_name="$1"
    local default_registry="$2"
    local default_image="$3"

    echo "Usage: ${script_name} [--registry <name>] [--image <name>] [--tag <value>]" >&2
    echo "Defaults:" >&2
    echo "  --registry ${default_registry}" >&2
    echo "  --image    ${default_image}" >&2
    echo "  --tag      YYYY-MM-DD.<git-short-commit>" >&2
}

parse_build_args() {
    local script_name="$1"
    local default_registry="$2"
    local default_image="$3"
    shift 3

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --registry)
                if [[ $# -lt 2 ]]; then
                    echo "ERROR: --registry requires a value." >&2
                    print_build_usage "$script_name" "$default_registry" "$default_image"
                    return 1
                fi
                registry="$2"
                shift 2
                ;;
            --image)
                if [[ $# -lt 2 ]]; then
                    echo "ERROR: --image requires a value." >&2
                    print_build_usage "$script_name" "$default_registry" "$default_image"
                    return 1
                fi
                image="$2"
                shift 2
                ;;
            --tag)
                if [[ $# -lt 2 ]]; then
                    echo "ERROR: --tag requires a value." >&2
                    print_build_usage "$script_name" "$default_registry" "$default_image"
                    return 1
                fi
                tag="$2"
                shift 2
                ;;
            -h|--help)
                print_build_usage "$script_name" "$default_registry" "$default_image"
                return 2
                ;;
            *)
                echo "ERROR: Unknown argument: $1" >&2
                print_build_usage "$script_name" "$default_registry" "$default_image"
                return 1
                ;;
        esac
    done

    if [[ -z "$registry" || -z "$image" || -z "$tag" ]]; then
        echo "ERROR: --registry, --image, and --tag values must be non-empty." >&2
        print_build_usage "$script_name" "$default_registry" "$default_image"
        return 1
    fi

    return 0
}
