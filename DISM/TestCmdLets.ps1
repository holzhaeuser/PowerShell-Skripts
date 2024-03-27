if ("{{ vswitch_type }}" -eq "Private" -or "{{ vswitch_type }}" -eq "Internal") {
    New-VMSwitch -Name "{{ vswitch_name }}" -SwitchType "{{ vswitch_type }}"
}
else {
    New-VMSwitch -Name "{{ vswitch_name }}" -AllowManagementOS $True -NetAdapterName "{{ netadapter_name }}"
}