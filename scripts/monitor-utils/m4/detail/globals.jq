to_entries
    | map("define(`GLOBAL_MONITOR_"
        + (.key | ascii_upcase)
        + "', `"
        + (.value | tostring | gsub("[`']"; ""))
        + "')dnl")
    | join("\n")
