*Distribute SSH Key

ansible-playbook -i inventory/poling/config/hosts.ini -b -u rodney -e Yobiesa01 -v inventory/poling/ansible/sshkey.yml --ask-pass

*Configure HA Proxy

ansible-playbook -i inventory/poling/config/hosts.ini --become --become-user=root -v inventory/poling/ansible/haproxy/haproxy.yml