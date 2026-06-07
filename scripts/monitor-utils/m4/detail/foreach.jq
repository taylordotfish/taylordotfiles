"__MONITOR_UTILS_TMP_" as $tmp_prefix
    | (add | keys_unsorted) as $fields
    | [
        ($fields[] | ascii_upcase | "ifdef(`MONITOR_"
            + .
            + "', `define(`"
            + $tmp_prefix
            + .
            + "', defn(`MONITOR_"
            + .
            + "'))')dnl"),
        (.[] | . as $m
            | $fields
            | map("define(`MONITOR_"
                + ascii_upcase
                + "', `"
                + ($m[.] // "" | tostring | gsub("[`']"; ""))
                + "')")
            | join("") + $ARGS.positional[0] + "`'dnl"),
        ($fields[] | ascii_upcase | "ifdef(`"
            + $tmp_prefix
            + .
            + "', `define(`MONITOR_"
            + .
            + "', defn(`"
            + $tmp_prefix
            + .
            + "'))', `undefine(`MONITOR_"
            + .
            + "')')dnl")
    ] | join("\n")
