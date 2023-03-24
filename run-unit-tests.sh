#!/bin/bash
failed="0"
for d in $(ls $WORKDIR) ; do
    pushd ${WORKDIR}/${d}
        echo "================= Running tests in ${WORKDIR}/${d} ====================================="
        bundle exec rake test
	    if [ "$?" != "0" ] ; then
              failed="1"
              echo "!!!!!!!!!!!!!! FAILED !!!!!!!!!!!!!!!!!!"
	    fi
        echo "========================================================================================="
        echo
    popd
done
exit $failed
