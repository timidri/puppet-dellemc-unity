# puppet_unity

This module provides types, providers and tasks to interact with a DellEMC Unity system via its Unisphere API.

#### Table of Contents

- [puppet_unity](#puppet_unity)
      - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Setup](#setup)
    - [Beginning with puppet_unity](#beginning-with-puppet_unity)
  - [Usage](#usage)
    - [Desired state management](#desired-state-management)
      - [resource: unity_job](#resource-unity_job)
      - [example](#example)
    - [Tasks and plans](#tasks-and-plans)
      - [task: list_jobs](#task-list_jobs)
      - [usage example](#usage-example)
  - [Limitations](#limitations)
  - [Development](#development)
  - [Release Notes/Contributors/Etc. **Optional**](#release-notescontributorsetc-optional)

## Description

This module contains a number of useful types, providers, tasks and plans to automate a DellEMC Unity storage system.

## Setup


### Beginning with puppet_unity

1. Install the module
1. Create a file `vsa.conf` (name is arbitrary) containing credentials of the Unisphere API host:

    ```json
    {
      "port": 443,
      "host": "my.unisphere.host.or.ip",
      "user": "admin",
      "password": "MySecretPassword123!"
    }
    ```

1. Create a device configuration file `devices.conf`

    ```ini
    [vsa]
    type unity
    url file:///absolute/path/to/vsa.conf
    ```

1. The bolt tasks need `faraday-cookie_jar` gem to be available in the bolt gem path to enable cookie handling during authenticated communication with the Unisphere API. Install the gem as follows:

    ```shell
    sudo /opt/puppetlabs/bolt/bin/gem install faraday-cookie_jar --no-ri --no-rdoc 
    ```

1. Create a Bolt inventory file to tell Bolt where the Unisphere API lives:

    ```yaml
    version: 2
    targets:
      - uri: my.unisphere.host.or.ip
        alias: unity
        config:
          transport: remote
          remote:
            remote-transport: unity
            user: admin
            password: MySecretPassword123!
    ```

    Note that it is also possible to specify the `port` but it's `443` by default.

## Usage

### Desired state management

#### resource: unity_job
This resource corresponds to the job object in Unisphere.
#### example

  ```shell
  puppet device --resource unity_job --target vsa --deviceconfig devices.conf --verbose
  ```
  ```puppet
  ...
  unity_job { 'N-6':
    description => 'Modify NTP Server',
    state => 5,
    progress_pct => 0,
    message_out => {
      'errorCode' => 100665589,
      'messages' => [
        {
          'locale' => 'en_US',
          'message' => 'A reboot is required to set the Date and Time. Please use the reboot dialog box from the GUI or specify allowDU/allowReboot option from the CLI to reboot and set the time. (Error Code:0x60008f5)'
        }
      ]
    },
    affected_resource => {},
    client_data => '',
}
...
```

### Tasks and plans

#### task: list_jobs
Lists all the jobs in the system.
#### usage example
```shell
bolt task run unity::list_jobs -t unity --inventoryfile inventory.yaml
```
```shell
Started on 192.168.1.219...
Finished on 192.168.1.219:
  {
    "jobs": [
      {
        "content": {
          "id": "N-1",
          "state": 4,
          "description": "Create the protection schedule",
          "progressPct": 100,
          "messageOut": {
            "errorCode": 0,
            "messages": [
              {
                "locale": "en_US",
                "message": "Success"
              }
            ]
          },
          "clientData": "",
          "affectedResource": {
          }
        }
      },
...
```


## Limitations

* Only reading of the unity_job instances and the task `list_jobs` are implemented.
* The type and module names most probably need to be improved

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
