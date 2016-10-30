# This hook replaces __FILE__ occurences in headers by "relative paths".
# Some packages (e.g. boost) use these in header functions (instead of just macros),
# so the string literals can get into other packages and introduce a run-time dependency.

# Caveats, etc: sometimes we used the technique of adding #line directive to the file,
# but that had bad interactions with #include __FILE__ and others: #15931.
# Note the macro interactions: (1) this won't help in files *using* e.g. assert;
# (2) if a header defined a macro with __FILE__, the location of __FILE__ will be
# in the string instead of location of where the macro expansion ends up.


# We need to do this late to minimize chance of headers being moved afterwards.
postFixupHooks+=(_relativize__FILE__)

_relativize__FILE__() {
(
    for output in $outputs; do
        cd "${!output}"
        if [ ! -d include ]; then
            continue
        fi
        find include \
            \( -name '*.hpp' -or -name '*.h' -or -name '*.ipp' -or -name '*.hh' \) \
            -exec sed \
                `# first, special case of #include __FILE__: use full path` \
                -e "/#[ \t]*include/s|\<__FILE__\>|${!output}/{}|g" \
                `# replace all other occurences, prepending by package name` \
                -e "s|\<__FILE__\>|\"$name/{}\"|g" \
                -i '{}' \;
    done
)
}

