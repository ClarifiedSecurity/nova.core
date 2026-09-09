# proxmox_networks

Reconciles Proxmox SDN zones, VNets and subnets from Providentia network data.

The role reads `providentia_networks`, exported by the `nova.core.providentia_v3`
inventory plugin from `/api/v3/<environment>/networks`.

## Usage

Run it as a Catapult pre-role:

```zsh
ctp network deploy
ctp network sync
ctp network plan
```

`deploy` creates missing SDN resources and leaves existing VNets untouched.
`sync` creates missing resources and updates existing Proxmox SDN resources to
match Providentia. `plan` prints the desired state and current Proxmox presence
without changing Proxmox.

## Providentia network config

Set the network `cloud_id` to the Proxmox VNet ID. Proxmox documents VNet IDs as
up to 8 characters, so keep `cloud_id` short for SDN-managed networks.

Add this to the network config map:

```yaml
proxmox:
  managed: true
  zone:
    name: cyberexercise
    type: simple
```

By default, the first managed Providentia network with `proxmox.zone` becomes
the exercise-level zone for every managed network that does not define its own
zone. If no network defines `proxmox.zone`, managed networks are created in a
simple zone named after the Providentia project.

The exercise-level zone can also be overridden in Catapult:

```yaml
proxmox_networks_zone:
  name: cyberexercise
  type: simple
```

For a VLAN zone, reference an existing Proxmox bridge. This role does not create
or edit physical/node bridges.

```yaml
proxmox_networks_zone:
  name: cyberexercise
  type: vlan
  bridge: vmbr0
```

Per-network overrides can be stored in the Providentia network config map:

```yaml
proxmox:
  managed: true
  vnet:
    isolate_ports: true
    tag: 120
  subnet:
    snat: true
```
