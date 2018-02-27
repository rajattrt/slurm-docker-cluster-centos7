#!/bin/bash
set -e

if [ "$1" = "slurmdbd" ]
then
    echo "---> Starting the MUNGE Authentication service (munged) ..."
    gosu munge /usr/sbin/munged

    echo "---> Starting the Slurm Database Daemon (slurmdbd) ..."

    until echo "SELECT 1" | mysql -h mysql -uslurm -ppassword 2>&1 > /dev/null
    do
        echo "-- Waiting for database to become active ..."
        sleep 2
    done
    echo "-- Database is now active ..."

    exec gosu slurm /usr/sbin/slurmdbd -Dvvv
fi


#turn this case true if you do not want to use the controller as a compute
if false
then
    if [ "$1" = "slurmctld" ]
    then
        echo "---> Starting the MUNGE Authentication service (munged) ..."
        gosu munge /usr/sbin/munged

        echo "---> Waiting for slurmdbd to become active before starting slurmctld ..."

        until 2>/dev/null >/dev/tcp/slurmdbd/6819
        do
            echo "-- slurmdbd is not available.  Sleeping ..."
            sleep 2
        done
        echo "-- slurmdbd is now active ..."

        echo "---> Starting the Slurm Controller Daemon (slurmctld) ..."
        exec gosu slurm /usr/sbin/slurmctld -Dvvv
    fi
fi

#turn this case true if you do want to use the controller as a compute
if true
then
    if [ "$1" = "slurm_ctl_as_compute" ]
    then
        echo "---> Starting the MUNGE Authentication service (munged) ..."
        gosu munge /usr/sbin/munged

        echo "---> Waiting for slurmdbd to become active before starting slurmctld ..."

        until 2>/dev/null >/dev/tcp/slurmdbd/6819
        do
            echo "-- slurmdbd is not available.  Sleeping ..."
            sleep 2
        done
        echo "-- slurmdbd is now active ..."

        echo "---> Starting the Slurm Node Daemon (slurmd) ..."

        /usr/sbin/slurmd
        
        echo "---> Starting the Slurm Controller Daemon (slurmctld) ..."
        
        exec gosu slurm /usr/sbin/slurmctld -Dvvv
    fi
fi

if [ "$1" = "slurmd" ]
then
    echo "---> Starting the MUNGE Authentication service (munged) ..."
    gosu munge /usr/sbin/munged

    echo "---> Waiting for slurmctld to become active before starting slurmd..."

    until 2>/dev/null >/dev/tcp/slurmctld/6817
    do
        echo "-- slurmctld is not available.  Sleeping ..."
        sleep 2
    done
    echo "-- slurmctld is now active ..."

    echo "---> Starting the Slurm Node Daemon (slurmd) ..."
    exec /usr/sbin/slurmd -Dvvv
fi

exec "$@"
