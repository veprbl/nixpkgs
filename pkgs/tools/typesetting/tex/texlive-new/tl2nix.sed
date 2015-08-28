# wrap whole file into an attrset
1itl: { # no indentation
$a}

# some packages start with a number :-/
s/^name (.*)/name "\1"/
#s/^depend (.*)/depend "\1"/

# trash packages we don't want
/^name .*\./s/^name (.*)/name trash.\1/

# form an attrmap per package
/^name /s/^name (.*)/\1 = {/p
/^$/,1i};

# extract md5 for runfiles
s/^containermd5 (.*)/  md5.run = "\1";/p
s/^doccontainermd5 (.*)/  md5.doc = "\1";/p
s/^srccontainermd5 (.*)/  md5.source = "\1";/p

# number of path components to strip, defaulting to 1 ("texmf-dist/")
s/^relocated 1/  stripPrefix = 0;/p

# extract version and clean unwanted chars from it
/^catalogue-version/y/ \/~/_--/
/^catalogue-version/s/[\#,:\(\)]//g
s/^catalogue-version_(.*)/  version = "\1";/p

# extract deps
s/^depend ([^.]*)$/  deps."\1" = tl."\1";/p

