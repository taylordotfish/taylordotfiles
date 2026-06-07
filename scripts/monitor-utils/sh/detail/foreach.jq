"__monitor_utils_foreach_invoke" as $func
    | (add | keys_unsorted) as $fields
    | [
        $func + "() {",
        ($fields | to_entries[] | "  local monitor_"
            + .value
            + "=\"${"
            + (.key + 1 | tostring)
            + "}\""),
        "  shift " + ($fields | length | tostring),
        "  \"$@\"",
        "}",
        (.[] | . as $m
            | $fields
            | map($m[.] // "")
            | . + $ARGS.positional
            | [$func] + map(@sh)
            | join(" "))
    ] | join("\n")
