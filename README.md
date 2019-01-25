# FRESCO - MATRIX

This repo contains functionality to make [FRESCO](https://github.com/aicis/fresco) work with the
[MATRIX](https://github.com/cryptobiu/MATRIX) benchmarking tool.

This includes classes for logging timings and printing logs in a format compatible with the MATRIX
framework (see [here](src/main/java/dk/alexandra/fresco/matrix/logging/)).

Also included is a small FRESCO benchmark program which can be run with MATRIX as a demo (see
[here](src/main/java/dk/alexandra/fresco/matrix/demo/)), and scripts and configurations required by
MATRIX in order to build and run the demo (see [here](MATRIX)).

Below we walk through how to run the demo using MATRIX. The walk through is tested on MacOs.

## Walkthrough

### Prerequisites

For this walkthrough we assume you have the following programs installed on your system: `python3`,
`pip3`, `git`, `java` and `maven`.

### Installing MATRIX

To install MATRIX we first clone the matrix repo.

```
git clone https://github.com/GuutBoy/MATRIX.git
```

**Note** here we clone a version of MATRIX with some fixes included, which are not merged into the
[main repo](https://github.com/cryptobiu/MATRIX). Once pull request #49 is merged in, you should use
the main repo instead.

We now move to the freshly cloned `MATRIX` directory and checkout the `1.2` branch like so: 

```
cd MATRIX
git checkout 1.2
```

We now install some requirements needed for MATRIX. 

**Note** you may want to set up a virtual environment for this step (if you are comfortable with
virtual environments). 

We install the requirements like so:

```
pip3 install -r requirements.txt
```

We are now ready to run our benchmark with MATRIX.

### Local Benchmark Execution

We now go through how to run our FRESCO benchmark program on our local machine. 


#### Setting Up For Local Execution

To do so we need a
configuration file for MATRIX. Luckly one is included included in
`ProtocolsConfigurations/Config_FRESCO_local.json`. The configuration looks as follows
```
{
  "protocol":"FRESCO-SPDZ",
  "CloudProviders":
  {
    "local":
    {
      "numOfParties":2,
      "git":
      {
        "gitBranch": ["master"],
        "gitAddress": ["https://github.com/aicis/fresco-matrix.git"]
      }
    }
  },
  "executableName": ["run.sh"],
  "configurations":
  [
    "matrix-distance.jar@-s@spdz@-Dspdz.preprocessingStrategy%DUMMY@-e@SEQUENTIAL_BATCHED",
    "matrix-distance.jar@-s@spdz@-Dspdz.preprocessingStrategy%DUMMY@-e@SEQUENTIAL"
  ],
  "numOfRepetitions":1,
  "numOfInternalRepetitions":10,
  "IsPublished": "true",
  "isExternal": "true",
  "workingDirectory": ["~/Projects/test-matrix"],
  "resultsDirectory": "/Users/psn/Projects/MATRIX-EXP/MATRIX/results2",
  "emails": ["peter.s.nordholt@alexandra.dk"],
  "institute":"The Alexandra Institute"
}
```

The configuration specifies that we are running the benchmarks locally, with two parties, and that
the experiment should be pulled from the `master` branch of this git repository. It also specifies
two `configurations` which will be run in the experiment. These configurations are simply the
commandline arguments that will be given to the specified `executableNames`, which is the script
that will run the experiment (in this case the `run.sh` script which can be found
[here](/MATRIX/run.sh)). You may notice that the `configurations` here is simply the name of a jar
file `matrix-distance.jar` followed by commandline arguments compatible with the FRESCO
`CmdLineUtil`. The `run.sh` essentially just runs the jar file and passes the arguments along (a
part from party address arguments which wil be generated at run time by `run.sh`). 

Before you run the benchmarks you want to change the paths given in `workingDirectory` and
`resultsDirectory`. `workingDirectory` indicates where MATRIX will pull the repo to on the machine
running the benchmark (in this case the local machine). `resultsDirectory` indicates the directory
in which MATRIX will place measurements gathered on from the repository. For more on the MATRIX
configuration see [here](https://github.com/cryptobiu/MATRIX/tree/1.2).

Finally, to make local execution work we need to make a few changes to the file
`Execution/fabfile.py`. First change the line

```
env.user = 'ubuntu'
```

To reflect your user name on the local machine (instead of the default `ubuntu`). Remove or comment out the line 

```
env.key_filename = ['YOUR-KEY']
```

and change the line:

```
path_to_matrix = 'YOU PATH TO MATRIX'
```

to reflect the path to the directory where you cloned the MATRIX repo.

#### Running Local Benchmarks with MATRIX

To start the MATRIX deployment tool we run (in the MATRIX directory we cloned above)

```
python3 main.py ProtocolsConfigurations/Config_FRESCO_local.json
```

This will give you the following menu:

```
Welcome to MATRIX system.
Please Insert your choice:
1. Deploy Menu
2. Execute Menu
3. Analysis Menu
4. Generate Circuits
5. Change Protocol Configuration
6. Exit
Your choice:
```

We will first go to the `Deploy Menu`. I.e., we pick option `1` and get: 

```
Choose cloud provider
1. AWS
2. Scaleway
3. Both
4. Local
5. Servers
6. Return
Your choice:
```

We pick option `4` and get:

```
Choose deployment task
1. Deploy Instance(s)
2. Create Key pair(s)
3. Create security group(s)
4. Get instances network data
5. Terminate machines
6. Change machines types
7. Start instances
8. Stop instances
9. Copy AMI
10. Return
```

For local deployment the only option we need here is to set up the network information, so we pick
option `4`. This will take us back to the main menu, but in the background MATRIX has generated
network information for our two parties and put it in `InstancesConfigurations` directory. 

In the main menu we now pick `Execute Menu` (option `2`) and get:

```
Choose task to be executed:
1. Preform pre process operations
2. Install Experiment
3. Execute Experiment
4. Execute Experiment with profiler
5. Execute Experiment with latency
6. Update libscapi
7. Return
Your choice:
```

Here we go directly to option `2` to install the experiment. This will pull this repo into the
directory specified in `workingDirectory` and build the demo.

To run the benchmark we will return to the `Execute Menu` and pick option `3`. This should run the
experiment with both of the two configurations given in the MATRIX configuration file, and will
generate some MATRIX compliant performance logs.

Finally, we can go to the `Analysis Menu` in the MATRIX tool and pick the option to `Download &
Analyze results`. This will "download" the logs generated during the experiment, generate an
excell file summarizing the results and put these files in the directory we specified above in the
MATRIX config file under `resultsDirectory`.

Now if we need to update our experiment and re-run it we can simply push the change to the git repo,
and proceed as above to re-install the experiment.

### AWS Benchmark Execution

Here we walkthrough how to execute the benchmark on AWS. 

#### Setting Up For AWS Execution

As for local execution we need a MATRIX configuration file and one is given in
`ProtocolsConfigurations/Config_FRESCO_aws.json`. The configuration looks as follows:

```
{
  "protocol":"FRESCO-SPDZ",
  "CloudProviders":
  {
    "aws":
    {
      "numOfParties":2,
      "instanceType": "c5.large",
      "regions":["eu-west-1a"],
      "git":
      {
        "gitBranch": ["master"],
        "gitAddress": ["https://github.com/aicis/fresco-matrix.git"]
      }
    }
  },
  "executableName": ["run.sh"],
  "configurations":
  [
    "matrix-distance.jar@-s@spdz@-Dspdz.preprocessingStrategy%DUMMY@-e@SEQUENTIAL_BATCHED",
    "matrix-distance.jar@-s@spdz@-Dspdz.preprocessingStrategy%DUMMY@-e@SEQUENTIAL"
  ],
  "preProcessTask": 8,
  "numOfRepetitions":1,
  "numOfInternalRepetitions":10,
  "IsPublished": "true",
  "isExternal": "true",
  "workingDirectory": ["~/Projects/test-matrix"],
  "resultsDirectory": "/Users/psn/Projects/MATRIX-EXP/MATRIX/results",
  "emails": ["peter.s.nordholt@alexandra.dk"],
  "institute":"The Alexandra Institute"
}
```

This more or less the same configuration as for the local execution, only now we specify that we
want to run on AWS on two instances of type `c5.large` in the `eu-west-1a` region. Again, you may
want to adjust the `workingDirectory` and `resultsDirectory` (note that the latter will still be a
directory on your local machine).

To do deployment to AWS, you need an AWS account and to set up your AWS credentials on your local
machine. See the MATRIX [README](https://github.com/cryptobiu/MATRIX) for links on how to do this.
**Note** this is an important step, if the AWS credentials are not setup the MATRIX tool will not be
able to interact with AWS.

We now need to generate a key to use with AWS for our benchmark. We can do this using the MATRIX
tool. 

**Note** MATRIX will put the generated key in the directory `~/Keys`. If we do not have this
directory, MATRIX will crash, so make we should sure it is there.

To generate the key we run

```
python3 main.py ProtocolsConfigurations/Config_FRESCO_aws.json
```

We go to the menu `Deploy Menu > AWS` and pick the `Create Key pair(s)` option. This will put a key in `~/Keys`. We now need to go edit the file `Execution/fabfile.py` so that the line 

```
env.key_filename = ['YOUR-KEY']
```

points to the path of your key (e.g., `~/Keys/[NAME OF YOUR KEY]`). Additionally, if we adjusted the
`env.user` variable above, then you should set it back to the default `ubuntu` value.

We also need to edit the file `GlobalConfigurations/regions.json` to reflect the name of name of our
new key (in the record named `eu-west-1`) and to enter a AWS security group for the instances we
want to deploy. **Note** this may not work if you have an old AWS account. If so, see below how to
set up in this case.

We can now return to the MATRIX tool and pick `Deploy Instance(s)` from the AWS deployment menu.
This should deploy the two AWS instances for our benchmark (**Note** MATRIX will take at least four
minutes to finish the deployment, so go get some coffee).

Once the instances are deployed we first need to go the `Execute Menu` and pick `install
experiment`. This will initially fail. We then need to go back to the `Execute Menu` and pick `pre
process` to install some libraries. We can now return to the `Execute Menu` and pick `install
experiments` (Yes, we need to do things in this odd order).

From this point, everything should work as for the local deployment (only the experiment is run on
the AWS instances). **Note** if we need to update our experiment, we do not need to do the pre
processing task again.



#### Alternative Setup for Old AWS Accounts

If there you have an old AWS account, there seems to be some issue with instances not being deployed
to a default VPC. Therefore, we need to edit the `GlobalConfigurations/regions.json` file a bit
differently. First we need to go to our AWS web console and create a VPC, we then need the
`subnetId` of this VPC. In the record in `GlobalConfigurations/regions.json` we still set the `key`
entry (as above) but we add an entry called `subnetid` with the id of our VPC. We also need to edit
the file `Deployment/aws_deploy.py`. Here we need to substitute the line

```
SecurityGroups=[global_config[regions[idx][:-1]]["securityGroup"]],
```

with the line 

```
SubnetId=global_config[regions[idx][:-1]]["subnetid"],
```

Additionally, once the instances are deployed (as described above) we need to go into the AWS
console and manually associate an appropriate security group with our new instances. You should also
make sure that your instances are given public ip-addresses.

(There is probably a more elegant way to do this, but this at least seems to work).
