# dellemc_unity

This module provides types, providers and tasks to interact with a DellEMC Unity system via its Unisphere API.

#### Table of Contents

- [dellemc_unity](#dellemc_unity)
      - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Setup](#setup)
    - [Beginning with dellemc_unity](#beginning-with-dellemc_unity)
  - [Usage](#usage)
    - [Resource Types](#resource-types)
      - [unity_job](#unity_job)
      - [unity_host](#unity_host)
    - [Tasks and plans](#tasks-and-plans)
      - [task: list_jobs](#task-list_jobs)
  - [Limitations](#limitations)
  - [Development](#development)
  - [Release Notes/Contributors/Etc. **Optional**](#release-notescontributorsetc-optional)

## Description

This module contains a number of useful types, providers, tasks and plans to automate a DellEMC Unity storage system.

## Setup

### Beginning with dellemc_unity

1. Install the module
1. Create a file `vsa.conf` (name is arbitrary) containing credentials of the Unisphere API host:

    ```json
    {
      "host": "my.unisphere.host.or.ip",
      "user": "admin",
      "password": "MySecretPassword123!"
    }
    ```

    Note that it is also possible to specify the `port` but it's `443` by default.

1. Create a device configuration file `devices.conf` like so:

    ```ini
    [vsa]
    type unity
    url file:///absolute/path/to/vsa.conf
    ```

1. The module needs the `faraday-cookie_jar` gem to function. Install the gem:

    ```shell
    sudo /opt/puppetlabs/puppet/bin/gem install faraday-cookie_jar --no-ri --no-rdoc
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

### Resource Types

#### unity_job

This resource corresponds to the job resource in Unisphere.

<!-- omit in toc -->
##### example

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

#### unity_host

This resource corresponds to the host resource in Unisphere.

<!-- omit in toc -->
##### example

  ```shell
  puppet device --resource unity_host --target vsa --deviceconfig devices.conf --verbose
  ```

  ```puppet
  ...
  unity_host { 'Host_1':
    description => 'test host 1',
    health => {
      'value' => 5,
      'descriptionIds' => ['ALRT_COMPONENT_OK'],
      'descriptions' => ['The component is operating normally. No action is required.']
    },
    type => 1,
    os_type => 'Linux',
  }
...
```

### Tasks and plans

#### task: list_jobs

Lists all the jobs in the system.

<!-- omit in toc -->
##### usage example

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

Please note that property names of the Puppet resource types are not necessarily equal to the property names of Unity objects. Puppet resource type properties need to be lowercase, so they are converted from CamelCase-d Unity properties like this: `messageOut => message_out`. Note that the tasks use Unity property names.

## Limitations

- Only reading of the unity_job instances and the task `list_jobs` are implemented.
- The type and module names most probably need to be improved

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using change log, put your release notes here (though you should consider using change log). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
