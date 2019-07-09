source $stdenv/setup

source $mirrorsFile

curlVersion=$(curl -V | head -1 | cut -d' ' -f2)

# Curl flags to handle redirects, not use EPSV, handle cookies for
# servers to need them during redirects, and work on SSL without a
# certificate (this isn't a security problem because we check the
# cryptographic hash of the output anyway).
curl=(
    curl
    --location
    --max-redirs 20
    --retry 3
    --disable-epsv
    --cookie-jar cookies
    --insecure
    --user-agent "curl/$curlVersion Nixpkgs/$nixpkgsVersion"
    $curlOpts
    $NIX_CURL_FLAGS
)

downloadedFile="$out"
if [ -n "$downloadToTemp" ]; then downloadedFile="$TMPDIR/file"; fi


tryDownload() {
    local url="$1"
    echo
    header "trying $url"
    local curlexit=18;

    success=

    if echo "$url" | grep -v softwareheritage; then break; fi

    # if we get error code 18, resume partial download
    while [ $curlexit -eq 18 ]; do
       # keep this inside an if statement, since on failure it doesn't abort the script
       if "${curl[@]}" -C - --fail "$url" --output "$downloadedFile"; then
          success=1
          break
       else
          curlexit=$?;
       fi
    done
}


finish() {
    local skipPostFetch="$1"

    set +o noglob

    if [[ $executable == "1" ]]; then
      chmod +x $downloadedFile
    fi

    if [ -z "$skipPostFetch" ]; then
        runHook postFetch
    fi

    exit 0
}


function base32to16() {
    base32="$1"
    base16=`echo -n "${outputHash}0===" | tr "0123456789abcdfghijklmnpqrsvwxyz" "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567" | base32 -d | od -t x1 -w33 -An | tr -d ' '`

    for i in `seq 64 -2 1`; do
        echo -n "$base16" | cut -b $i-`expr $i + 1` | tr -d '\r\n' | dd conv=lcase 2>/dev/null
    done
}


tryHashedMirrors() {
    if test -n "$NIX_HASHED_MIRRORS"; then
        hashedMirrors="$NIX_HASHED_MIRRORS"
    fi

    for mirror in $hashedMirrors; do
        echo $outputHash
        # TODO: handle other hash types
        outputHash_base16="$outputHash"
        if [ "$outputHashAlgo" == "sha256" ] && [ "$(echo -n $outputHash | wc -m)" -ne 64 ]; then
            outputHash_base16="$(base32to16 "$outputHash")"
        fi
        url="$(echo -n "$mirror" | sed -e "s/@outputHashAlgo@/$outputHashAlgo/g" -e "s/@outputHash@/$outputHash/g" -e "s/@outputHash_base16@/$outputHash_base16/g")"
        if "${curl[@]}" --retry 0 --connect-timeout "${NIX_CONNECT_TIMEOUT:-15}" \
            --fail --silent --show-error --head "$url" \
            --write-out "%{http_code}" --output /dev/null > code 2> log; then
            tryDownload "$url"

            # We skip postFetch here, because hashed-mirrors are
            # already content addressed. So if $outputHash is in the
            # hashed-mirror, changes from ‘postFetch’ would already be
            # made. So, running postFetch will end up applying the
            # change /again/, which we don’t want.
            if test -n "$success"; then finish skipPostFetch; fi
        else
            # Be quiet about 404 errors, which we interpret as the file
            # not being present on this particular mirror.
            if test "$(cat code)" != 404; then
                echo "error checking the existence of $url:"
                cat log
            fi
        fi
    done
}


# URL list may contain ?. No glob expansion for that, please
set -o noglob

urls2=
for url in $urls; do
    if test "${url:0:9}" != "mirror://"; then
        urls2="$urls2 $url"
    else
        url2="${url:9}"; echo "${url2/\// }" > split; read site fileName < split
        #varName="mirror_$site"
        varName="$site" # !!! danger of name clash, fix this
        if test -z "${!varName}"; then
            echo "warning: unknown mirror:// site \`$site'"
        else
            mirrors=${!varName}

            # Allow command-line override by setting NIX_MIRRORS_$site.
            varName="NIX_MIRRORS_$site"
            if test -n "${!varName}"; then mirrors="${!varName}"; fi

            for url3 in $mirrors; do
                urls2="$urls2 $url3$fileName";
            done
        fi
    fi
done
urls="$urls2"

# Restore globbing settings
set +o noglob

if test -n "$showURLs"; then
    echo "$urls" > $out
    exit 0
fi

if test -n "$preferHashedMirrors"; then
    tryHashedMirrors
fi

# URL list may contain ?. No glob expansion for that, please
set -o noglob

success=
for url in $urls; do
    if [ -z "$postFetch" ]; then
       case "$url" in
           https://github.com/*/archive/*)
               echo "warning: archives from GitHub revisions should use fetchFromGitHub"
               ;;
           https://gitlab.com/*/-/archive/*)
               echo "warning: archives from GitLab revisions should use fetchFromGitLab"
               ;;
       esac
    fi
    tryDownload "$url"
    if test -n "$success"; then finish; fi
done

# Restore globbing settings
set +o noglob

if test -z "$preferHashedMirrors"; then
    tryHashedMirrors
fi


echo "error: cannot download $name from any mirror"
exit 1
