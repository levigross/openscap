#!/bin/bash

. $builddir/tests/test_common.sh

set -e -o pipefail

function perform_test {
probecheck "rpmverify" || return 255

name=$(basename $0 .sh)
result=$(mktemp ${name}.out.XXXXXX)
echo "Result file: $result"

echo "Evaluating content."
$OSCAP oval eval --results $result $srcdir/${name}.xml || [ $? == 2 ]
echo "Validating results."
$OSCAP oval validate-xml --results $result
echo "Testing results values."
[ "$($XPATH $result 'string(/oval_results/results/system/tests/test[@test_id="oval:x:tst:1"]/@result)')" == "true" ]
echo "Testing syschar values."
[ "$($XPATH $result 'string(/oval_results/results/system/oval_system_characteristics/collected_objects/object[@id="oval:x:obj:1"]/@flag)')" == "complete" ]
[ "$($XPATH $result 'count(/oval_results/results/system/oval_system_characteristics/collected_objects/object[@id="oval:x:obj:1"]/reference)')" == "1" ]
[ "$($XPATH $result 'string(/oval_results/results/system/oval_system_characteristics/collected_objects/object[@id="oval:x:obj:2"]/@flag)')" == "complete" ]
[ "$($XPATH $result 'count(/oval_results/results/system/oval_system_characteristics/collected_objects/object[@id="oval:x:obj:2"]/reference)')" == "1" ]

rm $result
}

perform_test
