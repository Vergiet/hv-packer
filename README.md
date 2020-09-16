# Set of packer scripts to create Hyper-V VMs

## Requirements

* packer <=`1.5.4`. Do not use packer below 1.5.1. For previous packer versions use previous releases from this repository
* Microsoft Hyper-V Server 2016/2019 or Microsoft Windows Server 2016/2019 (not 2012/R2) with Hyper-V role installed as host to build your images
* firewall exceptions for `packer` http server (look down below)
* [OPTIONAL] Vagrant >= `2.2.5` - for `vagrant` version of scripts. Boxes (prebuilt) are already available here: [https://app.vagrantup.com/marcinbojko](https://app.vagrantup.com/marcinbojko)
* be aware, for 2016 - VMs are in version 8.0, for 2019 - VMs are in version 9.0. There is no way to reuse higher version in previous operating system. If you need v8.0 - build and use only VHDX.

## Usage

### Install packer from Chocolatey

```cmd
choco install packer --version=1.5.5 -y
```

### Add firewal exclusions for TCP ports 8000-9000 (default range)

```powershell
Remove-NetFirewallRule -DisplayName "Packer_http_server" -Verbose
New-NetFirewallRule -DisplayName "Packer_http_server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000-9000

```

### To adjust to your Hyper-V, please check variables below and/or in ./variables files - for

* proper VLAN ID (possible passing as variable `-var 'vlan_id=0'` ). Look to your build server NIC setings.
* proper Hyper-V Virtual Switch name (access to Internet will be required) (possible passing as variable `-var 'switch_name=vSwitch'`). Remember - creation of new switch by packer, instead of reusing existing one can cause lack of Internet access. If it's possible substitute variable with your current switch's name.
* proper URL for ISO images in packer's template (possible passing as variable `-var 'iso_url=file.iso'` ). Be warned - using your own or different images can fail the build, as for example image index or image name used by your ISO can be different then specified by script. Look at the bottom of this Readme to read how to find or use image index.
* proper checksum type (possible passing as variable `-var 'iso_checksum_type=sha256'` )
* proper checksum  (possible passing as variable `-var 'iso_checksum=aaaabbbbbbbcccccccddddd'` )

## Scripts

### Windows Machines

* all available updates will be applied (3 passes)
* latest version of chocolatey
* packages from a list below:

  |Package|Version|
  |-------|-------|
  |puppet-agent|5.5.19|
  |conemu|latest|
  |dotnetfx|latest|
  |sysinternals|latest|
* latest Nuget poweshell module
* puppet agent settings will be customized (`server=foreman.spcph.local`). Please adjust it (`/extra/scripts/phase-3.ps1`) to suit your needs. Puppet is set to be cleared and stopped after generalize phase

### Linux Machines

* Repositories:

  |Repository|Package|switch|
  |----------|------------|---|
  |Epel 7    |            |no|
  |Zabbix 4.2|zabbix-agent|can be switched off by `-z false`|
  |Puppet 5  |puppet-agent|can be switched off by `-p false`|
  |Webmin (CentOS7)|webmin|can be switched off by setting `-w false`|
  |Cockpit (CentOS8) |Cockpit|can be switched off by setting `-c false`|
  |-         |scvmmagent| can be switched off by setting `-h false`|
  |neofetch  |neofetch|no|

* [Optional] Linux machine with separated disk for docker
* [Optional] Linux machine for vagrant

Be aware, turning off latest System Center Virtual Machine Agent will cause System Center fail to deploy machines

### Info

* adjust `/files/provision.sh` to modify package's versions/servers.
* change `"provision_script_options"` variable to:
  * -p (true/false) - switch Install Puppet on/off
  * -w (true/false) - switch Install Webmin on/off (CentOS7 only)
  * -h (true/false) - switch Install Hyper-V integration services on/off
  * -u (true/false) - switch yum update all on/off (usable when creating previous than `latest` version of OS)
  * -z (true/false) - switch Zabbix-agent installation
  * -c (true/false) - switch Cockpit installation (CentOS8 only)
Example:

```json
"provision_script_options": "-p false -u true -w true -h false -z false"
```

* `prepare_neofetch.sh` -  default banner during after the login - change required fields you'd like to see in `provision.sh`

## Templates Windows 2019

### Hyper-V Generation 2 Windows Server 2019 Standard Image

Run `hv_win2019_std.ps1` (Windows)

#### 2019 Standard Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

* ./extra/files/gen2-2019/std/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1            => /bootstrap.ps1

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2019 SERVERSTANDARD</Value>
    </MetaData>
</InstallFrom>
```

### Hyper-V Generation 2 Windows Server 2019 Datacenter Image

Run `hv_win2019_dc.ps1` (Windows)

#### 2019 Datacenter Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

* ./extra/files/gen2-2019/dc/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1            => /bootstrap.ps1

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2019 SERVERDATACENTER</Value>
    </MetaData>
</InstallFrom>
```

## Templates Windows 2016

### Hyper-V Generation 2 Windows Server 2016 Standard Image

Run `hv_win2016_std.ps1` (Windows)

#### 2016 Standard Generation 2 Prerequisites

For Generation 2 prepare `secondary.iso` with folder structure:

* ./extra/files/gen2-2016/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

This template uses this image name in Autounattendes.xml. If youre using different ISO you'll have to adjust that part in proper file and rebuild `secondary.iso` image.

```xml
<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME </Key>
        <Value>Windows Server 2016 SERVERSTANDARD</Value>
    </MetaData>
</InstallFrom>
```

## Windows Server Images

### Hyper-V Generation 2 Windows Server 1903 Standard Image

If you need changes For - prepare `secondary1903.iso` with folder structure:

* ./extra/files/gen2-1903/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_winserver_1903.ps1`

### Hyper-V Generation 2 Windows Server 1909 Standard Image

If you need changes For - prepare `secondary1909.iso` with folder structure:

* ./extra/files/gen2-1909/Autounattend.xml     => /Autounattend.xml
* ./extra/scripts/hyper-v/bootstrap.ps1        => /bootstrap.ps1

Run `hv_winserver_1909.ps1`

## Templates CentOS 8.x

### Hyper-V Generation 2 CentOS 8.1 Image

Run `hv_centos81.ps1`

### Warnings - CentOS 8

* if required change `switch_name` parameter to switch's name you're using. In most situations packer manages it fine but there were a cases when it created new 'internal' switches without access to Internet. By design this setup will fail to download and apply updates.
* if needed - change `iso_url` variable to a proper iso name
* packer generates v8 machine configuration files (Windows 2016/Hyper-V 2016 as host) and v9 for Windows Server 2019/Windows 10 1809
* credentials for Windows machines: Administrator/password (removed after sysprep)
* credentials for Linux machines: root/password
* for Windows based machines adjust your settings in ./scripts/phase-2.ps1
* for Linux based machines adjust your settings in ./files/gen2-centos/provision.sh and ./files/gen2-centos/puppet.conf

### Vagrant support - CentOS 8

Experimental support for vagrant machines `hv_centos81_vagrant.ps1`

## Templates CentOS 7.x

### Warnings - CentOS Docker

* if required change `switch_name` parameter to switch's name you're using. In most situations packer manages it fine but there were a cases when it created new 'internal' switches without access to Internet. By design this setup will fail to download and apply updates.
* if needed - change `iso_url` variable to a proper iso name
* packer generates v8 machine configuration files (Windows 2016/Hyper-V 2016 as host) and v9 for Windows Server 2019/Windows 10 1809
* credentials for Windows machines: Administrator/password (removed after sysprep)
* credentials for Linux machines: root/password
* for Windows based machines adjust your settings in ./scripts/phase-2.ps1
* for Linux based machines adjust your settings in ./files/gen2-centos/provision.sh and ./files/gen2-centos/puppet.conf
* no `docker` repo will be added  and no `docker-related` packages will be installed - this build creates and mount separated volume (size specified by variable) for docker

### Hyper-V Generation 2 CentOS 7.8

Run `hv_centos78_docker.ps1`

### Hyper-V Generation 2 CentOS 7.8 Image with extra docker volume

Run `hv_centos78_docker.ps1`

### Hyper-V Generation 2 CentOS 7.7

Run `hv_centos77_docker.ps1`

### Hyper-V Generation 2 CentOS 7.7 Image with extra docker volume

Run `hv_centos77_docker.ps1`

### Vagrant support - CentOS 7.x

Experimental support for vagrant machines `hv_centos78_vagrant.ps1` for CentOS 7.8
Experimental support for vagrant machines `hv_centos77_vagrant.ps1` for CentOS 7.7



## Known issues

### I have general problem not covered here

Please create an issue in github. There is slim chance I'll find the time to be your personal helpdesk ;)

### I'd like to contribute

Sure. If I can ask - create your PR in smaller sizes, this is repo used for my work, so smaller changes - bigger chances to succeed.

### Infamous UEFI/Secure boot WIndows implementation

During the deployment secure keys are stored in *.vmcx file and are separated from *.vhdx file. To countermeasure it - there is added extra step in a form of (`/usr/local/bin/uefi.sh`) script that will check for existence of CentOS folder in EFI and will add extra entry in UEFI.
In manual setup you can run it as a part of your deploy. In SCVMM deployment I'd recommend using `RunOnce` feature.

### ~~On Windows Server 2019/Windows 10 1809 image boots to fast for packer to react~~

[https://github.com/hashicorp/packer/issues/7278#issuecomment-468492880](https://github.com/hashicorp/packer/issues/7278#issuecomment-468492880)

Fixed in version 1.4.4.  Do not use lower versions

### ~~When Hyper-V host has more than one interface Packer sets {{ .HTTPIP }} variable to inproper interface~~

Fixed in version 1.4.4. Do not use lower versions
~~No resolution so far, template needs to be changed to pass real IP address, or there should be connection between these addresses. Limiting these, end with timeout errors.**~~

### Packer version 1.3.0/1.3.1 have bug with `windows-restart` provisioner

[https://github.com/hashicorp/packer/issues/6733](https://github.com/hashicorp/packer/issues/6733)

### Packer won't run until VirtualSwitch is created as shared

[https://github.com/hashicorp/packer/issues/5023](https://github.com/hashicorp/packer/issues/5023)
Will be fixed in 1.4.x revision

### I have problem how to find a proper WIM  name in Windows ISO to pick proper version

You can use number. If you have 4 images on the list of choice - use `ImageIndex` with proper `Value`

```xml
<ImageInstall>
    <OSImage>
        <InstallFrom>
            <MetaData wcm:action="add">
                <Key>/IMAGE/INDEX </Key>
                <Value>2</Value>
            </MetaData>
        </InstallFrom>
        <InstallTo>
            <DiskID>0</DiskID>
            <PartitionID>2</PartitionID>
        </InstallTo>
    </OSImage>
</ImageInstall>
```

### On Windows machines, build break during updates phase, when update cycles are interfering with each other

Increase variable  `update_timeout` in `./variables/*.json` file - this will create longer pauses between stages, allowing cycles to complete before jumping to another one.

### Why don't you use ansible instead of shell scripts for provisioning

I wish. In short - Windows. These builds should be done with minimum effort (Hyper-V role is enough). Building custom ansible station with lots of checks right now fails in my tryouts.

## About

* Marcin Bojko - marcin(at)bojko.com.pl
* [https://marcinbojko.dev/](https://marcinbojko.dev/)

Work based on [https://github.com/jacqinthebox/packer-templates.git](https://github.com/jacqinthebox/packer-templates.git)
