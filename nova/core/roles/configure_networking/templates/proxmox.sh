#!/bin/sh

# Logging script output
exec > /tmp/network.log 2>&1

set -e # exit when any command fails

# Timeout duration in seconds
TIMEOUT=180 # 5 minutes
START_TIME=$(date +%s)

# Wait until the pve-cluster service is running
until systemctl is-active --quiet pve-cluster; do
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
    if [ $ELAPSED_TIME -ge $TIMEOUT ]; then
        echo "Timed out waiting for pve-cluster service to start"
        exit 1
    fi
    echo "Waiting for pve-cluster service to start..."
    sleep 3
done

{# Looping over Providentia interfaces to find the connection interface #}
{% for interface in interfaces %}
{% if interface.connection %}

    MGMT_INTERFACE_NAME={{ configure_networking_proxmox_mgmt_interface_name }}
    NODE_NAME={{ configure_networking_proxmox_node_name | default("$(hostname)") }}

    {# Looping over connection IP addresses #}
    {% for ip_address in interface.addresses %}
    {% if ip_address.connection %}

        {% if (ip_address.mode == 'ipv4_static') and (ip_address.gateway != none) %}

            {# Adding IPv4 addresses with GW for interface #}
            pvesh set /nodes/$NODE_NAME/network/$MGMT_INTERFACE_NAME --type bridge --address {{ ip_address.address | ansible.utils.ipaddr('address') }} --netmask {{ ip_address.address | ansible.utils.ipaddr('netmask') }} --gateway {{ ip_address.gateway }}


        {% elif (ip_address.mode == 'ipv4_static') and (ip_address.gateway == none) %}

            {# Adding IPv4 addresses without GW for interface #}
            pvesh set /nodes/$NODE_NAME/network/$MGMT_INTERFACE_NAME --type bridge --address {{ ip_address.address | ansible.utils.ipaddr('address') }} --netmask {{ ip_address.address | ansible.utils.ipaddr('netmask') }}

        {% elif (ip_address.mode == 'ipv6_static') and (ip_address.gateway != none) %}

            {# Adding IPv6 addresses with GW for interface #}
            pvesh set /nodes/$NODE_NAME/network/$MGMT_INTERFACE_NAME --type bridge --address6 {{ ip_address.address | ansible.utils.ipaddr('address') }} --netmask6 {{ ip_address.address | ansible.utils.ipaddr('prefix') }} --gateway6 {{ ip_address.gateway }}

        {% elif (ip_address.mode == 'ipv6_static') and (ip_address.gateway == none) %}

            {# Adding IPv6 addresses without GW for interface #}
            pvesh set /nodes/$NODE_NAME/network/$MGMT_INTERFACE_NAME --type bridge --address6 {{ ip_address.address | ansible.utils.ipaddr('address') }} --netmask6 {{ ip_address.address | ansible.utils.ipaddr('prefix') }}

        {% endif %}

    {% endif %}
    {% endfor %}

{% endif %}
{% endfor %}

# Reload network configuration
pvesh set /nodes/$NODE_NAME/network