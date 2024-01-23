[ -f ~/.config/monitordef ] && . ~/.config/monitordef

monitors() {
    local monitors=${monitordef_names-}
    local propertydefs=${monitordef_properties-}
    local tab=$(printf '\t')
    local newline='
'
    local num_defined=$(printf '%s'"${monitors:+\\t}" "$monitors" |
        grep -o "$tab" |
        wc -l
    )
    local script=$(printf '%s' 's/^\s*\([0-9]\+\):\s*\S*\s*' \
        '\([0-9]\+\)[^x]*x\([0-9]\+\)[^+]*' \
        '+\([0-9]\+\)+\([0-9]\+\)\s*\(\S\+\).*' \
        '/\1\t\2\t\3\t\4\t\5\t\6/p'
    )
    local IFS="$newline"
    set -f
    for line in $(xrandr --listactivemonitors | sed -n "$script"); do
        local name=$(printf '%s' "$line" | cut -f6)
        local priority=$(printf '%s\t' "$monitors" |
            grep -o "^\(.*$tab\)*$name$tab" |
            grep -o "$tab" |
            wc -l
        )
        if [ "$priority" -eq 0 ]; then
            num_defined=$((num_defined+1))
            priority=$num_defined
        fi
        local properties=$(printf '%s' "$propertydefs" | cut -f"$priority")
        properties=${properties:--}
        printf '%s\t%s\t%s\n' "$(printf '%s' "$line" | cut -f1-6)" \
            "$priority" "$properties"
    done
    set +f
}
