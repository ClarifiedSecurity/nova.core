# win_test_pending_reboot

This role checks if a Windows host has a pending reboot and reboots it if necessary. It uses Ansible facts to determine the reboot status.

## Requirements

None

## Role Variables

none

## Dependencies

None

## Example

```yml
# Include the role
- name: Including the win_test_pending_reboot module...
  ansible.builtin.include_role:
    name: nova.core.win_test_pending_reboot
```
