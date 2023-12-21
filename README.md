# relearning_immutable_infrastructure_golden_image_ptb20231219_04

## Install Packer

```console
$ brew tap hashicorp/tap
$ brew install hashicorp/tap/packer
```

## Usage

Get Subscrion ID

```console
$ az login
$ az account show --query "{ subscription_id: id }" -o json | jq -r .subscription_id
```

Set pkrvars

```console
$ cp linux/packer.auto.pkrvars.hcl.example linux/packer.auto.pkrvars.hcl
$ cp windows/packer.auto.pkrvars.hcl.example windows/packer.auto.pkrvars.hcl
# Modify linux/packer.auto.pkrvars and windows/packer.auto.pkrvars
```

Run packer(linux)

```console
$ script/setup-ubuntu-packer
$ cd linux
$ packer init .
$ packer validate .
$ packer fmt .
$ packer build .
```

Run packer(windows)

```console
$ script/setup-windows-packer
$ cd windows
$ packer init .
$ packer validate .
$ packer fmt .
$ packer build .
```
