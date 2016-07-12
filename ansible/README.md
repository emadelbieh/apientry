# Ansible playbooks

The `hosts` file has the hosts to set up.

```
vim hosts
```

EC2 setup
---------

Hosts are assumed to be:

- Ubuntu Trusty LTS instances;
- with an `ubuntu` user (AWS default); and
- has the `admin2` keypair (see `keys/`).

Bootstrapping
-------------

Run the `setup.yml` playbook to Bootstrap all machines and/or update machines to the latest config. This is [idempotent](http://docs.ansible.com/ansible/glossary.html).

```
make setup
```

SSH
---

To SSH into machines, add the pem keys to your ssh-agent:

```
make keys
```

Then simply SSH into hosts:

```
ssh ubuntu@54.84.208.240
```
