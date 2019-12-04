<domain type='kvm'>
<name>${name}</name>
<memory unit='GiB'>${memory_gb}</memory>
<vcpu placement='static'>${vcpu}</vcpu>
<resource>
<partition>/machine</partition>
</resource>
<os>
<type arch='x86_64' >hvm</type>
<boot dev='hd'/>
<boot dev='network'/>
</os>
<features>
<acpi/>
<apic/>
</features>
<clock offset='utc'>
<timer name='rtc' tickpolicy='catchup'/>
<timer name='pit' tickpolicy='delay'/>
<timer name='hpet' present='no'/>
</clock>
<on_poweroff>destroy</on_poweroff>
<on_reboot>restart</on_reboot>
<on_crash>destroy</on_crash>
<pm>
<suspend-to-mem enabled='no'/>
<suspend-to-disk enabled='no'/>
</pm>
<devices>
<disk type='file' device='disk'>
<driver name='qemu' type='qcow2'/>
<source file='${vm_img}'/>
<backingStore/>
<target dev='vda' bus='virtio'/>
<alias name='virtio-disk0'/>
<address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>
</disk>
<interface type='bridge'>
<mac address='${provisioning_mac_address}'/>
<source bridge='${provisioning_bridge}'/>
<target dev='vnet0'/>
<model type='rtl8139'/>
<alias name='net0'/>
<address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
</interface>
<interface type='bridge'>
<mac address='${baremetal_mac_address}'/>
<source bridge='${baremetal_bridge}'/>
<target dev='vnet1'/>
<model type='rtl8139'/>
<alias name='net1'/>
<address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
</interface>
<serial type='pty'>
<source path='/dev/pts/6'/>
<target type='isa-serial' port='0'>
<model name='isa-serial'/>
</target>
<alias name='serial0'/>
</serial>
<console type='pty' tty='/dev/pts/6'>
<source path='/dev/pts/6'/>
<target type='serial' port='0'/>
<alias name='serial0'/>
</console>
<input type='mouse' bus='ps2'>
<alias name='input0'/>
</input>
<input type='keyboard' bus='ps2'>
<alias name='input1'/>
</input>
<graphics type='vnc' port='5900' autoport='yes' listen='127.0.0.1'>
<listen type='address' address='127.0.0.1'/>
</graphics>
<video>
<model type='cirrus' vram='16384' heads='1' primary='yes'/>
<alias name='video0'/>
<address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
</video>
<memballoon model='virtio'>
<alias name='balloon0'/>
<address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
</memballoon>
</devices>
<seclabel type='dynamic' model='selinux' relabel='yes'>
<label>system_u:system_r:svirt_t:s0:c689,c792</label>
<imagelabel>system_u:object_r:svirt_image_t:s0:c689,c792</imagelabel>
</seclabel>
<seclabel type='dynamic' model='dac' relabel='yes'>
<label>+107:+107</label>
<imagelabel>+107:+107</imagelabel>
</seclabel>
</domain>
