#!/bin/bash -x
# vim:set ts=8 sw=4 sts et ai nu:

function die() {
    exit 1
}

rm -rf ./output/rfc-index || die
mkdir 'output/rfc-index' || die

cp -p ./rfc-index.css         ./output/rfc-index/ || die
cp -p ./output/rfc-index.html ./output/rfc-index/ || die

pushd ./output
zip -r rfc-index.zip ./rfc-index
popd

rm -rf ./output/rfc-index || die

exit 0
