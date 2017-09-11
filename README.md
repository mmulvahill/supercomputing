Supercomputing
==============

This started as an initial testing of approaches to massively parallel computing on Google Cloud. The aim is now expaned to researching and documenting all high-thoroughput (HTC) and high-performance computing (HPC) options and researching which computing options fit with which workload type.

Key terminology
---------------

-   High-performance computing (HPC)
-   Individual programs that take advantage of multiple cores and multiple nodes typicaly via MPI.
-   High-throughput computing (HTC)
-   Many independent executions of a single serial program.

Open Science Grid
-----------------

-   [OpenScienceGrid Training](https://swc-osg-workshop.github.io/OSG-UserTraining-RMACC17/index.html)
    -   Best for HTC, individual wall times up to several hours, has preemption but automatically handles it (retries job)
-   OpenScience Grid links
    -   [Submitting and monitoring jobs](https://swc-osg-workshop.github.io/OSG-UserTraining-RMACC17/novice/DHTC/04-HTCondor-Submitting.html)
    -   ['Scaling up' example](https://swc-osg-workshop.github.io/OSG-UserTraining-RMACC17/novice/DHTC/04a-ScalingUp-python.html)
    -   [HTCondor Manual](http://research.cs.wisc.edu/htcondor/manual/latest/)
    -   [Data storage and transfer guidelines](https://support.opensciencegrid.org/support/solutions/articles/12000006512-guidelines-for-data-managment-in-osg-storage-and-transfer)

Cluster computing on Google Cloud
---------------------------------

-   [Overview of cluster computing options](https://cloud.google.com/solutions/using-clusters-for-large-scale-technical-computing)
    -   Slurm, Univa Grid Engine, and LSF Symphony are all also possible solutions. Especially if HPC clustering is required.
-   [HTCondor tutorial](https://cloud.google.com/solutions/high-throughput-computing-htcondor)

Scientific workflow software
----------------------------

-   [Pegasus](https://pegasus.isi.edu/documentation/tutorial_scientific_workflows.php)

Google Compute Engine Cost of Dedicated vs Preemptible VMs
----------------------------------------------------------

``` r
num_jobs <- 10000
perjob_runtime <- 10 # minutes

# per core-hour ---> scales linearly
cost <- c(hicpu = 0.03545, hicpu_preempt = 0.0075, himem = 0.1184/2,
          himem_preempt = 0.025/2)

num_jobs * perjob_runtime / 60 * cost
```

    ##         hicpu hicpu_preempt         himem himem_preempt 
    ##      59.08333      12.50000      98.66667      20.83333
