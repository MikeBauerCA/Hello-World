#!/usr/bin/env bash
set +x

# Unlock the keyring
echo 'jenkins' | gnome-keyring-daemon --unlock

# set -x
# bright files download ds "SHARC18.BRIGHT.CBL.LOADLIB(HELLO)" -f bin -b
echo 'bright files list ds "SHARC18.BRIGHT.TEST.LOADLIB" | grep -q "SHARC18.BRIGHT.TEST.LOADLIB"'
if bright files list ds "SHARC18.BRIGHT.TEST.LOADLIB" | grep -q "SHARC18.BRIGHT.TEST.LOADLIB"; then
    echo "SHARC18.BRIGHT.TEST.LOADLIB already exists"
else
    echo "SHARC18.BRIGHT.TEST.LOADLIB does not exist. Create it."
    echo 'bright files create bin "SHARC18.BRIGHT.TEST.LOADLIB"'
    bright files create bin "SHARC18.BRIGHT.TEST.LOADLIB"
fi

# bright files upload ftds bin "SHARC18.BRIGHT.TEST.LOADLIB(HELLO)" -b
tries=20
wait=2
function submitJCL () {
    ds=$1

    echo 'bright jobs submit data-set "' $ds '--rff jobid --rft string"'
    jobid=`bright jobs submit data-set $ds --rff jobid --rft string`
    echo $jobid
    echo ''

    echo 'bright jobs view job-status-by-jobid' $jobid '--rff retcode --rft string'
    retcode=`bright jobs view job-status-by-jobid $jobid --rff retcode --rft string`
    echo $retcode
    echo ''
    
    counter=0
    while (("$counter" < $tries)) && [ "$retcode" == "null" ]; do
        ((counter++))
        sleep $wait
        
        echo 'bright jobs view job-status-by-jobid' $jobid '--rff retcode --rft string'
        retcode=`bright jobs view job-status-by-jobid $jobid --rff retcode --rft string`
        echo $retcode
        echo ''
    done

    if [ "$retcode" == "null" ]; then
       echo $ds 'timed out'
       echo ''
       exit 1
    elif [ "$retcode" != "CC 0000" ]; then
       echo $ds 'did not complete with CC 0000'
       echo ''
       exit 1
    else
       echo 'Success'
       echo ''
    fi
}

submitJCL "SHARC18.BRIGHT.JCL(IEBCOPY)"