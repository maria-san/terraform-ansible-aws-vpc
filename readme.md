# Terraform AWS VPC
Provision AWS VPC written in Terraform using Ansible

## Terraform 
### Default Config :
One NAT gateway per availability zone
### Variables :
  - project : Name of the project
  - region : AWS region to use
  - vpc_name : Name to give the VPC
  - vpc_cidr_block : Primary CIDR of VPC
  - azs : A list of availability zones in the region
  - tags : A map of tags to add to all resources

## Ansible
### Playbooks
  - Create State Store

    Run: 
    ```
    ansible-playbook ansible/create_state_store.yaml 
    ```
  - Create VPC

    Run: 
    ```
      ansible-playbook ansible/create_vpc.yaml 
    ```

## Cleanup
Run this playbook to destroy all resources. 

```
  ansible-playbook ansible/create_vpc.yaml --tags=never
```