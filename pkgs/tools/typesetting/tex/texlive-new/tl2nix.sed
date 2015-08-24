# wrap whole file into an attrset
1itl: { # no indentation
$a}

# some packages start with a number :-/
# TODO: a better solution
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
s/^srccontainermd5 (.*)/  md5.src = "\1";/p
# extract version
s/^catalogue-version (.*)/  version = "\1";/p

# extract deps for collections and schemes
/^category (Collection|Scheme)/,/^$/s/^depend ([^.]*)$/  deps."\1" = tl."\1";/p

#/^runfiles/,/^[^ ]/s/ RELO
