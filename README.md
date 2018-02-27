# Slurm Docker cluster on CentOS 7

Slurm cluster using docker-compose.
The compose file creates named volumes for persistent storage of MySQL data files as well as
Slurm state and log directories.

## Containers and Volumes

The compose file will run the following containers:

* mysql
* slurmdbd
* slurmctld (head node)
* compute1 (slurmd) (compute node)
* compute2 (slurmd) (compute node)

The compose file will create the following named volumes:

* etc_munge         ( -> /etc/munge     )
* etc_slurm         ( -> /etc/slurm     )
* slurm_jobdir      ( -> /data          )
* var_lib_mysql     ( -> /var/lib/mysql )
* var_log_slurm     ( -> /var/log/slurm )

## Building the Docker Image

To build the image locally:

```console
$ docker build -t slurm-docker-cluster:17.02.9 .
```

## Starting the Cluster

Run `docker-compose` to instantiate the cluster:

```console
$ docker-compose up -d
```

## Register the Cluster with SlurmDBD

To register the cluster to the slurmdbd daemon, run the `register_cluster.sh`
script:

```console
$ ./register_cluster.sh
```

> Note: Wait a few seconds for the cluster daemons to become ready before registering
> the cluster.  Otherwise, you may get an error such as
>  **sacctmgr: error: Problem talking to the database: Connection refused**.
> You can check the status of the cluster by viewing the logs: `docker-compose
> logs -f`

## Accessing the Cluster

Use `docker exec` to run a bash shell on the controller container:

```console
$ docker exec -it slurmctld bash
```

From the shell, you can execute the slurm commands, for example:

```console
[root@slurmctld /]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
computes*    up   infinite      2   idle compute[1-2]
all          up   infinite      3   idle compute[1-2],slurmctld
[root@slurmctld /]# srun -N 2 -n 2 --partition=all hostname
slurmctld
compute2
```

## Deleting the Cluster

To remove all containers and volumes, run:

```console
$ docker rm -f slurmdbd mysql slurmctld compute1 compute
$ docker volume rm slurmdockercluster_etc_munge slurmdockercluster_etc_slurm slurmdockercluster_slurm_jobdir slurmdockercluster_var_lib_mysql slurmdockercluster_var_log_slurm
```
