<network>
  <name>${name}</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='${name}' stp='on' delay='0'/>
  <ip address='${ip}' netmask='${netmask}'>
    <dhcp>
      <range start='${range_start}' end='${range_end}'/>
    </dhcp>
  </ip>
</network>
