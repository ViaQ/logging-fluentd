#!/bin/bash
failed="0"
for d in $(ls $WORKDIR) ; do
    pushd ${WORKDIR}/${d}
        echo 
        bundle exec rake test
        echo 
	    if [ "$?" != "0" ] ; then
              failed="1"
	    fi
    popd
done
exit $failed
