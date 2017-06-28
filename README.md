# Introduction

Mesosphere Enterprise DC/OS is a comprehensive platform for building,
running and scaling modern enterprise applications based on Apache
Mesos. It provides efficient resource isolation and sharing across
distributed applications or frameworks. This software enables resource
sharing in a fine-grained manner, improving cluster utilization.

When customers run Mesosphere Enterprise DC/OS on HPE, they can expect
to achieve greater agility, efficiency, and resilience. HPE and
Mesosphere are working together to enable the ease of deployment and
management of their joint solution using OneView as the focal point of
integration.

# Solution Overview 

This solution uses Ansible to automate and therefore dramatically speed
up the deployment of a small cluster of Mesosphere DC/OS nodes on HPE
infrastructure. The project was deployed in two phases. HPE C7000
BladeSystem was leveraged for this solution in phase 1; in phase 2 we
used HPE Synergy. The Ansible playbook allows the user to deploy a
cluster of three DC/OS master nodes, one DC/OS public agent node, and
two DC/OS private agent nodes.

# Solution Components 

## Hardware

The following hardware components were utilized:

|                                |                                        | 
|--------------------------------|----------------------------------------|
| **Component**                      | **Purpose**                                |
| HPE ProLiant BL460cGen8 Blades | DC/OS master and agent nodes (Phase 1) |
| HPE ProLian BL460c Gen9 Blade  | Bootstrap node (Phase 1)               |
| HPE SY480 Gen9                 | All nodes (Phase 2)                    |


## Software Stack

The following software components were utilized:

|                                                |                   |    
|------------------------------------------------|-------------------|
| **Component**                                      | **Version**       |
| Mesosphere DC/OS                               | 1.8.8 (Phase 1)   |                                                                     
|                                                | 1.9 (Phase 2)     |
| Ansible                                        | 2.2               |
| Python                                         | 2.7.9             |
| HPE OneView                                    | 3.00.05 (Phase 1) |
|                                                | 3.00.07 (Phase 2) |
| HPE Insight Control server provisioning (ICsp) | 7.6 (Phase 1)     |
| Image Streamer                                 | 3.00.05 (Phase 2) |
| Ansible module for HPE OneView                 | 3.1.1             |

## Mesosphere DC/OS

In phase 1, we used OpenSource DC/OS version 1.8.8 and 1.9.

In phase 2, we used Enterprise DC/OS version 1.9

## Management Software Stack
### HPE OneView

HPE OneView 3.00.05 running as a VMware appliance was used during this
integration work for phase 1. Enclosure was imported, server hardware
and VirtualConnect interconnect modules discovered.

<img src="./media/image1.png" width="720" height="358" />

For phase 2, we used HPE Composer (powered by HPE OneView) V3.00.07, and
a Synergy 12000 composed of 3 frames. The frames were equipped with two
Image Streamer module V3.00.05.

### HPE ICsp

For the C-Class implementation (phase 1), HPE Insight Control Server
Provisioning 7.6.0 running as a VMware appliance was used during this
integration work. For the second phase, we did not use ICsp. A Windows
based Media server was also setup to host OS distribution.

### Python

The Ansible module for HPE OneView requires at least Python 2.7.9. We
installed this side by side with the system Python library using the
following instructions:

#### *Step1: Install GCC*

Firstly, make sure that you have gcc package installed on your system.
Use following command to install gcc if you don't have it installed.

> yum install gcc

#### *Step 2: Download Python2.7*

Download [*Python*](https://www.python.org/) using following command
from python official site. You can also download latest version in
place of specified below.

> cd /opt  
> wget --no-check-certificate[
> ](https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz)[*https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz*](https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz)

#### *Step 3: Extract Archive and Compile*

Use below set of commands to extract Python source code and compile it
on your system using altinstall.

> tar -xvf Python-2.7.13.tgz  
> cd Python-2.7.13  
> ./configure  
> make altinstall  # make altinstall is used to prevent replacing the default python binary file /usr/bin/python.

#### *Step 4: Check the Python Version*

Check the latest version installed of python using below command

> $ python2.7 -V  
> Python 2.7.13

### HPE OneView SDK for Python

The HPE OneView SDK for Python is also a requirement. It can be
installed using the following instructions:

> git clone https://github.com/HewlettPackard/python-hpOneView.git  
> cd python-hpOneView  
> sudo python2.7 setup.py install

### Composable Infrastructure Pack for Mesosphere DC/OS

This pack available from [*HPE
Github*](https://github.com/HewlettPackard/dcos-hpe-oneview) bundles a
set of tools used to build the entire solution

*   Kickstart file for CentOS 7.2 and RedHat 7.2 (used for C-Class only)
*   ICsp script for loading SSH key in target OS (used for C-Class only)
*   Ansible playbooks and associated scripts for deploying the above and
    also the DC/OS components
*   Artifact Bundle to load in Synergy Image Streamer (used for Synergy only)

You can simply clone the repo using:

> cd ~  
> git clone https://github.com/HewlettPackard/dcos-hpe-oneview

### Ansible

We used Ansible 2.2.0 on a CentOS 7 system (virtual machine), which we
call the Ansible Station throughout the document.

<img src="./media/image2.png" width="496" height="52" />

### Ansible Module for HPE OneView/ICsp

The latest OneView module for Ansible was used. It can be installed with
the following instructions:

> cd ~  
> git clone <https://github.com/HewlettPackard/oneview-ansible.git>  
> export ANSIBLE_LIBRARY=~/oneview-ansible/library  
> export PYTHONPATH=$PYTHONPATH:$ANSIBLE_LIBRARY


# Proof-of-concept lab environment - C7000 (Phase 1)

## Compute resource configuration

HPE assembled a proof-of-concept lab environment for DCOS which consists
of 9xBL460 server (8xGen8 and 1xGen9) in a C-Class Blade C7000
enclosure. The C7000 enclosure was configured with VirtualConnect
interconnect modules.

## Storage configuration

THE HPE servers were configured to use local storage using the local
SmartArray controller. Each server was configured with a single disk, in
a RAID 0 configuration.

## Network configuration

The following network configuration was implemented:

<img src="./media/image3.png" width="640" height="360" />

The router in the lab was configured to route between all networks. It
is also configured with a DHCP Proxy Agent, so that a single DHCP Server
(192.168.1.1) is able to distribute IP addresses in different scopes,
one for each network. This server also provides a role of name server
(DNS), with forwarder enabled to the internet. DHCP is also set to
automatically register/unregister names in the DNS server.

_**Notes:** HPE servers are provisioned in the lab with DHCP. In a production
environment, it is recommended to assign DHCP reservations, to make sure
that IP addresses of the target DC/OS nodes will never change. This is
required because DC/OS identifies machines by IP._

The network environment needs to be able to access the Internet during
the provisioning of the cluster. This is the case of our lab and each
network has direct access to Internet. Internet access was setup using
an IPCop appliance running on VMware
([*http://www.ipcop.org/*](http://www.ipcop.org/)). IPCop was also used
to provide VPN access to the lab environment.

_**Notes:** Configuration will need to be adapted if operations are performed behind
a corporate firewall._

## HPE OneView configuration

In HPE OneView we have created the networks required for the desired
configuration (See diagram in chapter [*Network
configuration*](#network-configuration))

<img src="./media/image4.png" width="720" height="314" />

We then configured a Server Profile Template for each type of nodes with
the following details:

* Bootstrap Node: 2 network connections (Deployment and Protected Zone), BL460 Gen9

* Master Node: 2 network connections (Deployment and Protected Zone), BL460 Gen8

* Agent Node: 2 network connections (Deployment and Private Zone), BL460 Gen8

* Public Agent Node: 2 network connections (Deployment and Public DMZ), BL460 Gen8

<img src="./media/image5.png" width="720" height="285" />

_**Notes:** Although we created those Server Profile Templates manually, chapter
[*Full infrastructure as code*](#full-infrastructure-as-code) shows how
to create those artifacts with code_

### HPE ICsp Configuration

In Phase 1, we used ICsp (Insight Control Server Provisioning) to
perform unattended installation of Operating Systems on target nodes.
DC/OS currently supports running on CoreOS, CentOS, and RHEL. To appeal
to the widest audience and simplify configuration, CentOS was chosen for
this proof of concept.So we started from a standard RedHat 7.2 OS Build
plan and adapted this to deploy CentOS 7.2 instead.

The following changes were implemented in the custom CentOS build plan:

1.  Populate CentOS distro in ICsp Media server as **/centos72-x64**

2.  Copy **RedHat 7.2 Kickstart** configuration file as **CentOS 7.2 x64
    en\_us Kickstart**

3.  Edit **CentOS 7.2 x64 en\_us Kickstart** and cut/paste the kickstart
    file provided as part of the Pack

4.  Create a new script called **DCOS - Install SSH Key** and cut/paste
    content from script provided as part of the Pack

5.  Edit Step6 of OS build plan and change Parameter to:
    **@\_\_OPSW-Media-LinURI@/centos72-x64**

6.  Edit Step7 of OS build plan and change to use **CentOS 7.2 x64
    en\_us Kickstart** created in step 2 and 3

7.  Add a final step in OS build plan called, **DCOS - Install SSH Key**
    which calls the Unix script created in step 4

This OS build plan called **DCOS - CentOS 7.2 x64 Scripted Install** is
used for the building of all our nodes in the cluster

<img src="./media/image6.png" width="720" height="443" />

_**Notes:** Later on during the development of the solution we also validated the
deployment on RHEL 7.2. The Kickstart file for RHEL7.2 is also provided
in the solution. You can choose between CentOS 7.2 or RHEL7.2, by simply
changing the ICsp OS build plan in the custom group\_vars files_

### iLO Configuration

All iLO of servers involved in the DC/OS cluster should be set with a
common administrative account. There are scripts to do this, leveraging
the Single Sign On (SSO) from OneView and iLO of managed server-hardware
([*https://github.com/HewlettPackard/POSH-HPOneView/wiki/Creator-iLO*](https://github.com/HewlettPackard/POSH-HPOneView/wiki/Creator-iLO))

### Ansible configuration

We configured an ansible.cfg configuration file with the following
parameters:

````yaml
[defaults]  
log_path = /root/log/dcos_play.log  
callback_whitelist = profile_tasks  
library = /root/oneview-ansible/library/  
host_key_checking = False  
inventory = hosts  
roles_path = roles  
forks = 50  
````

* **log\_path** allows us to get a log of each Playbook run in a log file

* **callback\_whitelist** allows to get information about time spent in each play during the run.

* **library** points to where we installed the OneView Python library (see chapter [*Python library*](#_4d34og8)).

* **inventory** points to the file in the local folder, which contains the definition of our environment to build

* **roles\_path** is the local folder where our 2 roles (**dcos-node** and **hpe-oneview-server**) are located

* **forks** was changed to 50 (default is 5) to allow more parallelism during task execution

The solution uses a **group\_var/all** configuration file which has to be customized as explained below:

````yaml
# DCOS Settings  
DCOS_GENERATE_CONFIG_PATH: '/root/dcos-cache/dcos_generate_config.sh'  
DCOS_CLUSTER_NAME: 'DCOS-ONEVIEW'  
DCOS_BOOTSTRAP_URL: 'http://bootstrap.cilab.net'
````

It is recommended to cache the dcos\_generate\_config.sh file which is a
big file. **DCOS\_GENERATE\_CONFIG\_PATH** sets the location of the
cached file on the Ansible Station. **DCOS\_CLUSTER\_NAME** sets the
DC/OS Cluster name. The Boostrap URL is used by all nodes to install
DC/OS

_**Notes:** This allows to easily change the version of the DC/OS software to use
for the installation._

The following variables apply to ICsp:

````yaml
icsp: 192.168.1.20                     # ICsp appliance IP Address  
icsp_username: Administrator           # ICsp user name  
icsp_password: <YourPasswordGoesHere>  # ICsp password  
osbp_custom_attributes:  
  - SSH_CERT: "{{ lookup('file', '~/.ssh/root_ansible.pub') }}"
````

_**Notes:** The SSH\_CERT points to the public SSH key to be used by Ansible._

The next section set username and password for iLOs of servers in the
environment:

````yaml
#iLO Credentials  
server_username: demopaq                 # iLO credentials for the target server that will be registered in ICsp  
server_password: <YourPasswordGoesHere>  # iLO password  
````

Next, we define the DNS domain name and the DNS server IP address:

````yaml
# Network Settings  
domain_name: "cilab.net"
dns_server: 192.168.1.1
````

Finally we define the properties of the 2 interfaces, which shall be set
to use DHCP:

````yaml
network_config:  
  hostname: "{{ inventory_hostname }}"   
  domain: "{{ domain_name }}"  
  interfaces:  
    - macAddress: "{{ server_profile.connections[0].mac }}"  
      enabled: true   
      dhcpv4: true  
      ipv6Autoconfig:  
      vlanid: -1  
    - macAddress: "{{ server\_profile.connections\[1\].mac }}"  
      enabled: true  
      dhcpv4: true   
      ipv6Autoconfig: false  
      virtualInterfaces:  
````

In addition to the **group\_vars/all**, we have servers specific
configuration files to store the name of the OneView server profile to
use, the ICsp OS Build plan to execute and the role of each server
group. We have a file for each type of server:

* group\_vars/dcos-bootstrap

````yaml
# OneView Settings  
ov_template: 'DCOS Bootstrap Node'  
os_build_plan: 'DCOS - RHEL 7.2 x64 Scripted Install'  
#os_build_plan: 'DCOS - CentOS 7.2 x64 Scripted Install' 
````

* group\_vars/dcos-masters

````yaml
# OneView Settings  
ov_template: 'DCOS Master Node'  
os_build_plan: 'DCOS - RHEL 7.2 x64 Scripted Install'  
#os_build_plan: 'DCOS - CentOS 7.2 x64 Scripted Install'  
node_type: 'master'
````

* group\_vars/dcos-private-agents

````yaml
# OneView Settings  
ov_template: 'DCOS Private Agent Node'   
os_build_plan: 'DCOS - RHEL 7.2 x64 Scripted Install'  
#os_build_plan: 'DCOS - CentOS 7.2 x64 Scripted Install'  
node_type: 'slave'
````

* group\_vars/dcos-public-agents

````yaml
# OneView Settings  
ov_template: 'DCOS Public Agent Node'  
os_build_plan: 'DCOS - RHEL 7.2 x64 Scripted Install'  
#os_build_plan: 'DCOS - CentOS 7.2 x64 Scripted Install'  
node_type: 'slave_public'
````

The details about the HPE OneView appliance to use can be found in a
configuration file called: **oneview_config.json.** This is where we set the IP
address, API Version and credentials to the HPE OneView appliance.

### Mesosphere DC/OS

We downloaded the DC/OS software from:
[*http://*](http://downloads.dcos.io/dcos/stable/dcos_generate_config.sh)[*downloads.dcos.io/dcos/stable/dcos\_generate\_config.sh*](http://downloads.dcos.io/dcos/stable/dcos_generate_config.sh)

The file is cached on the Ansible station in a folder. By default the
script looks for it in **/root/dcos-cache**. This is configured in
group\_vars/all

### Using HPE Composable Infrastructure to provision DC/OS Cluster

HPE's composable infrastructure provides an unified API that uses modern
REST protocols to create, aggregate, and host internal IT resources so
automation tools can provision on-demand and pragmatically. Developers
don't need to have a detailed understanding of the underlying physical
elements. By connecting automation tools with HPE OneView, bare-metal
infrastructure can be directed the same way as virtual and public cloud
resources.

## Use case 1 - Day 0 DC/OS Deployment

Here are the steps to provision HPE on DCOS using composable
infrastructure for a configuration with:

* 1 bootstrap node (used to install all nodes)
* 3 master nodes
* 2 private agent nodes
* 1 public agent node

This is described by our Ansible inventory **hosts** file:

````yaml
# There is only one bootstrap node  
[dcos-bootstrap]  
bootstrap  

# Masters should be an odd number  
[dcos-masters]  
master1  
master2  
master3  

# There are 2 types of agents, public and private  
[dcos-agents:children]  
dcos-public-agents  
dcos-private-agents  

# We start with 1 public agent  
[dcos-public-agents]  
agent1  

# We start with 2 private agents  
[dcos-private-agents]  
agent2  
agent3  

# All nodes are either bootstrap, masters, or agents  
[all-nodes:children]  
dcos-bootstrap  
dcos-masters  
dcos-agents
```` 

The full provisioning of the solution is initiated by running the
following command:

> ansible-playbook ov\_dcos.yml -vvv -e "ansible\_python\_interpreter=/usr/local/bin/python2.7"

where **ov\_dcos.yml** is the main playbook provided in the solution.

The playbook contains a series of plays:

```yaml
- name: Install all Physical Nodes  
  hosts: all-nodes  
  vars:  
    ov_osbp: "{{ os_build_plan }}"  
    ov_profile: "{{ ov_template }}"  
  gather_facts: no  
  roles:  
    - hpe-oneview-server  

- name: All nodes are DC/OS Nodes  
  hosts: all-nodes  
  gather_facts: yes  
  roles:  
    - dcos-node  
 
- name: Collect configuration of nodes  
  hosts: all-nodes  
  gather_facts: yes  
  tasks:  
    - name: Link Certificate Authorities # required on CentOS because DC/OS compilation is done on Ubuntu  
      file: src=/etc/ssl/certs/ca-bundle.crt dest=/etc/ssl/certs/ca-certificates.crt state=link  
    - include: tasks/detect-public-ip.yml  

- name: Generate DC/OS Bootstrap  
  hosts: dcos-bootstrap  
  gather_facts: no  
  tasks:  
    - include: tasks/bootstrap.yml  

- name: Install DC/OS Masters and Agents  
  hosts: dcos-masters,dcos-agents  
  gather_facts: no  
  tasks:  
    - include: tasks/install.yml  
````

The sequencing of the task in this playbook is the following:

<img src="./media/image7.png" width="634" height="362" />

The blue tasks are the ones running on the Ansible machine (localhost)
and using the Composable Infrastructure REST API. The grey tasks are
Ansible tasks running over SSH on target machines (once provisioned with
an OS)

Let's look in more details each of the plays from **ov\_dcos.yml**

````yaml
- name: Install all Physical Nodes  
  hosts: all-nodes  
  vars:  
    ov_osbp: "{{ os_build_plan }}"  
    ov_profile: "{{ ov_template }}"
  gather_facts: no
  roles:
    - hpe-oneview-server
````

This task provisions all nodes in parallel. That is the bootstrap
system, the masters and the agents using a **hp-oneview-server** role.
The **hpe-oneview-server**, provisions a server using HPE OneView and
ICsp.

The description of the **hpe-oneview-server** role is located in the
folder **./roles/hpe-oneview-server**. The **file
./roles/hpe-oneview-server/tasks/main.yml** calls
**./roles/hpe-oneview-server/tasks/deploy.yml**. This role will:

1.  use the **group\_vars/dcos-bootstrap**,
    **group\_vars/dcos-masters**, **group\_vars/dcos-private-agents**
    and **group\_vars/dcos-public-agents** for setting group specific
    variables such as the name of the OneView profile templates to use
    and ICsp build plan to execute

2.  Create the server profiles in HPE OneView from template provided and
    assign it to an available server-hardware in our pool of resources
    (this uses the HPE OneView REST API)

<img src="./media/image8.png" width="619" height="296" />

3.  Power the servers on

4.  Register the servers in ICsp, using the iLO IP address (this uses
    the HPE ICsp REST API)

5.  Pass the network configuration set in **group\_vars/all** to ICsp
    (stored as ICsp custom properties). (this uses the HPE ICsp
    REST API)

6.  Deploy the OS on these servers using ICsp, and the OS build plan
    provided in custom group\_vars files (this uses the HPE ICsp
    REST API)

<img src="./media/image9.png" width="648" height="302" />

_**Notes:** The tasks in the **hpe-oneview-server** role all run on the Ansible
Station, as instructed by the **deleguate\_to: localhost**, as
illustrated below:_

````yaml
- name: Create Server Profiles  
  oneview_server_profile:  
    config: "{{ playbook_dir }}/../oneview_config.json"  
    data:  
      server_template: "{{ ov_profile }}"  
      name: "{{ inventory_hostname }}"  
  delegate_to: localhost
````

After this play is finished, all servers have been provisioned, and an
SSH key has been installed so that the next play can continue on the
target host. The next play is the following:

````yaml
- name: All nodes are DC/OS Nodes
  hosts: all-nodes  
  gather_facts: yes  
  roles:  
    - dcos-node  
````

It applies to all-nodes and it uses another custom role called
**dcos-node** which installs all the software prerequisites for DC/OS
nodes, independent of the node types. The description of this role in
located in **/roles/dcos-node** and the
**/roles/dcos-node/tasks/main.yml** file describes the different steps:

1.  Installs and configures docker
    (**/roles/dcos-node/tasks/docker.yml**)

2.  Installs curl, bash, iputils, tar, xz, unzip, ipset, ntp, ntpdate

3.  Stops the firewall

4.  Starts and enables ntpd

5.  Create a folder for **/dcos**

Steps 2, 3, 4 and 5 are described in
**/roles/dcos-node/tasks/dcos-deps.yml**

After this task is terminated, all nodes are ready to install DC/OS.

The next step runs against all nodes, and collects public IP addresses
using the task: **/tasks/detect-public-ip.yml**. This script, fetches
the public network interface and the public IP of each node, and stores
it as Ansible facts (**public\_iface** and **public\_ip**) for the given
node:

````yaml
- name: Collect configuration of nodes  
  hosts: all-nodes  
  gather_facts: yes  
  tasks:  
    - name: Link Certificate Authorities # required on CentOS because DC/OS compilation is done on Ubuntu  
      file: src=/etc/ssl/certs/ca-bundle.crt dest=/etc/ssl/certs/ca-certificates.crt state=link
    - include: tasks/detect-public-ip.yml
````

The script to extract the public IP address is the following:

````yaml
- name: Set Public Network Interface  
  shell: "ifconfig | grep eno | cut --delimiter=: -f 1"  
  register: if_name  
- set_fact: public_iface={{ if_name.stdout }}  
    
- name: Detect Public IP
  set_fact: public_ip={{ hostvars[inventory_hostname]\['ansible_' + public_iface]['ipv4']['address'] }}  

- debug: var=public_ip
````

Once we know the IP layout of the provisioned servers we can start
preparing the DC/OS installation on the bootstrap node. This done by a
script called **/tasks/bootstrap.yml**

````yaml
- name: Generate DC/OS Bootstrap  
  hosts: dcos-bootstrap  
  gather_facts: no  
  tasks:  
    - include: tasks/bootstrap.yml
````

This is use use **dcos\_generate\_config.sh** to generate a DC/OS
configuration, based on the IP layout. It also starts a nginx docker
container to host the configuration. Once this is finished, the
bootstrap node is ready to accept other nodes installation over the URL:
**http://bootstrap.cilab.net**. We can initiate the last step, which
installs masters and agents (in parallel)

````yaml
- name: Install DC/OS Masters and Agents  
  hosts: dcos-masters,dcos-agents  
  gather_facts: no  
  tasks:  
    - include: tasks/install.yml
````

The tasks **/tasks/install.yml** expects a variable called
**node\_type** set to either **master, slave or public\_slave.** We set
this variable in the group\_var custom files.

When the playbooks terminates, we can see that it was successful (and
it took about 1 hours and 22 minutes to complete):

<img src="./media/image10.png" width="720" height="201" />

To validate the configuration we can run the following validation
procedure provided by Mesosphere:

1.  Install jq

> wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64  
> chmod +x ./jq-linux64  
> cp jq-linux64 
> /usr/bin/jq  

2.  Retrieve public agents IP addresses

> curl -s http://localhost:1050/system/health/v1/nodes | jq -r '.\[\] | map(select(.role == "agent\_public")) | .\[\].host\_ip'  
> 192.168.22.101

3.  Retrieve private agents IP addresses

> curl -s http://localhost:1050/system/health/v1/nodes | jq -r '.\[\] | map(select(.role == "agent")) | .\[\].host\_ip'  
> 192.168.33.102  
> 192.168.33.101

4.  Export those IP and install dig from bind-utils

> export SLAVE\_HOSTS=192.168.33.101,192.168.33.102  
> export PUBLIC\_SLAVE\_HOSTS=192.168.22.101  
> yum install bind-utils -y

5.  Add test user

> source /opt/mesosphere/environment.export  
> python /opt/mesosphere/active/dcos-oauth/bin/dcos\_add\_user.py [*albert@bekstil.net*]  
> source /opt/mesosphere/active/dcos-integration-test/test\_env.export  
> cd /opt/mesosphere/active/dcos-integration-test

6.  Run validation test

> py.test -m 'not ccm'

This should result in the following:

> ===================== 1 tests deselected by "-m 'not ccm'" =====================  
> ============= 52 passed, 3 skipped, 1 deselected in 372.21 seconds =============

Once this is validated, we can now operate our brand new DC/OS cluster
by accessing **http://master1/\#/dashboard/** or any of the other
masters.

<img src="./media/image11.png" width="720" height="426" />

We can also select the Node view to validate our 3 Agents (1 public and
2 private), up and running.

<img src="./media/image12.png" width="720" height="423" />
  
## Use case 2 - Adding an Agent node to a live DC/OS cluster

Because the Ansible playbook have been designed to be idempotent
(meaning that when run multiple times it will only make the changes to
bring the existing configuration on par with the desired state, as
described by the inventory **hosts** file), we can add node in the DC/OS
cluster by simply adding new nodes in the hosts file. In our
environment, we added an **agent4** to the list of private agents:

````yaml
[dcos-private-agents]  
agent2  
agent3  
agent4
````

And reran the same Ansible playbook, and waited for the end of it to
refresh the Nodes view. The 4<sup>th</sup> agent shows up in the node
list as a Healthy node.

<img src="./media/image13.png" width="720" height="424" />

## Use case 3 - Removing an Agent node

We have created a separate playbook to remove an agent from the cluster.
This playbooks will operate on nodes listed in the
**dcos-evicted-agent** section at the end of the inventory hosts file:

````yaml
[dcos-evicted-agents]  
agent4
````

In our case, we are evicting agent 4. So, we should also remove it from
the private agents list of that same hosts file:

````yaml
[dcos-private-agents]
agent2  
agent3
````

Once this is done we can run the following ansible playbook:

> ansible-playbook **ov\_dcos\_clean\_agent.yml** -vvv -e "ansible\_python\_interpreter=/usr/local/bin/python2.7"

This will first drain all services of all dcos-evicted-agents and then
delete the HPE OneView server profiles associated with these nodes and
return those resources to the available compute pool of resources.

## Use case 4 - Decomposing and returning resources to free pools

We have created another ansible playbook for destroying completely the
DC/OS cluster and returning all the compute resources to the free pool
of resources. The playbook is called **ov\_dcos\_decompose\_all.yml**,
and it should be invoked (with care) using the following command:

> ansible-playbook ov\_dcos\_decompose\_all.yml -vvv -e "ansible\_python\_interpreter=/usr/local/bin/python2.7"

_**Notes:** Be extremely careful with this playbook as no question is asked and the
entire cluster will be deleted_

## Full infrastructure as code

While for this PoC, we have created the server profile templates in HPE
OneView using the GUI, we can also use Ansible and yaml to describe
those templates and store them in your prefered code management
solution. This is particularly attractive in DevOps environments where
it is important that everything be managed as code (including the
components of the infrastructure). We have provided an example of
Ansible playbook to create a Server Profile Template in HPE OneView
called **create\_server\_profile\_template.yml.** These should be
adapted to match the target network configuration.

# Proof-of-concept lab environment - Synergy (Phase 2)

## Compute resource configuration

HPE assembled a proof-of-concept lab environment for DCOS which consists
of 18xSY480 Gen 9 servers in 3 Synergy frames.

## Storage configuration

THE HPE servers were configured to use the Synergy Image Streamer for
the OS Volume. The test does not include setting up external storage for
DC/OS agents.

## Network configuration

In this second phase a flat network was used, so all nodes are on the
same physical network.

## HPE Composer configuration

In HPE Composer (OneView) we have created a single Server Profile
Template for all nodes with the following details:

* 1 network connection
* Server Hardware Type: SY480 Gen9

<img src="./media/image14.png" width="720" height="344" />

## HPE Image Streamer configuration

We configured Image Streamer to have an OS Deployment Plan

<img src="./media/image15.png" width="720" height="370" />

This OS Deployment plan has a number of attributes:

**dhcphost** and **fqdn** to pass the hostname and the fully qualified
name of the system to provision. **MGMT** and **interface\_name** to
pass the interface used for networking, **SSH\_CERT1** and
**SSH\_CERT2** for the SSH key used by Ansible.

_**Notes:** This is a temporary workaround as there is a current limitation on the
length of a plan attribute._

The OS Build plan is referencing a golden image and an OS build plan.
The OS Build Plan has the steps which will happen to transform a Golden
Image into a dedicated OS Volume. In most case this steps are applying
changes on the OS Volume, using the input parameters of the Build Plan
(hostname, SSH Key).

<img src="./media/image16.png" width="720" height="370" />

## Image Streamer Golden Image

We created a Golden image for this test, which contains the following:

* RedHat Enterprise Linux 7.3
* Yum configured to point to a RHEL7.3 repo

<img src="./media/image17.png" width="720" height="366" />

_**Notes:** A similar golden image should be built and referenced by the OS
Deployment Plan provided in the artifact bundle of this solution before
it can be reused._

## Importing the solution artifact bundle

We created an artifact bundle with the following components:

* 1 x OS build plan
* 8 x Plan Scripts used by the OS build plan

<img src="./media/image18.png" width="720" height="370" />

In order to use this solution, you should:

1.  Download the artifact bundle from [Github](https://github.com/HewlettPackard/dcos-hpe-oneview)
2.  Import the artifact bundle into Image Streamer

    <img src="./media/image19.png" width="263" height="182" />

3.  Extract components from bundle (1 OS Build plan and 8 plan scripts)

    <img src="./media/image20.png" width="305" height="166" />

    <img src="./media/image21.png" width="594" height="286" />

4.  Build appropriate golden image following instructions provided by this [whitepaper](https://github.com/HewlettPackard/image-streamer-rhel/blob/master/docs/HPE%20Synergy%20Image%20Streamer%20RHEL%207.3%20Capture.pdf)

5.  Create a Deployment Plan which associates the imported OS build plan
    and the created golden image. Leave all attribute values blank

    <img src="./media/image22.png" width="375" height="259" />

## Use case 1 - Day 0 DC/OS Deployment

We used the same Ansible playbook, but adapted some of the files only
when the architecture imposed a different approach. To do this we used a
new variable in **group\_vars/all** called HARDWARE\_ARCHITECTURE which
should be set to either

*   HPE-CCLASS
*   HPE-SYNERGY
*   HPE-DL

Then we provided a custom file for each architecture, for example:
docker-on-HPE-SYNERGY.yml and docker-on-HPE-CCLASS.yml. Finally within
Ansible, we have a single playbook which references: docker-on-{{
HARDWARE\_ARCHITECTURE }}.yml

_**Notes:** We provided implementation for HPE-CCLASS and HPE-SYNERGY but not yet
HPE-DL._

We also added a few more variables in **group\_vars/all**:

*   INTERFACE\_NAME: ens3f4 : hold the name of the interface to be used
    for public networking (and SSH traffic used by Ansible)

*   DCOS\_BOOTSTRAP\_URL: 'http://bootstrap.{{ domain\_name }}' : holds
    the fqdn of the bootstrap machine

*   management\_network\_name: 'Mgmt A' : holds the name of the
    Management Network in the OneView Server profile

We can invoke the playbook the same way as in Phase 1:

> ansible-playbook ov\_dcos.yml -vvv -e "ansible\_python\_interpreter=/usr/local/bin/python2.7"

<img src="./media/image23.png" width="527" height="404" />

Provisioning was down from 1h22mn to 36mn using the ImageStream instead
of a PXE boot software such as ICsp.

_**Notes:** Use cases 2 (adding nodes) and 3 (removing agent nodes) was also tested
with Synergy, and works exactly the same way as described in Phase 1._

# Summary 

This solution leverages HPE OneView and HPE Composable Infrastructure to
provision a Mesosphere DC/OS Cluster, ready to run workload. The solution
can provision the cluster from a set of available compute resources in
an HPE Composable Infrastructure, in less than 90mn using Ansible
(C-Class) and even less than 35 minutes (Synergy and ImageStreamer).
The solution is fully automated and consistent, allowing to truly manage
your infrastructure as code. The solution can be used as an example to
build other solutions.
