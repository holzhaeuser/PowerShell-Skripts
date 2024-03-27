Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.2-1.msi -OutFile ${env.tmp}\wazuh-agent; msiexec.exe /i ${env.tmp}\wazuh-agent /q WAZUH_MANAGER='10.0.3.254' WAZUH_AGENT_GROUP='WindowsServer,Suricata' WAZUH_AGENT_NAME='NAME' WAZUH_REGISTRATION_SERVER='10.0.3.254' 



Copy-Item -Path "\\EXA-DC\Freigabe\Programme\Suricata-7.0.2-1-64bit.msi" -Destination "C:\Users\mm";
Start-Process -FilePath "C:\Users\mm\Suricata-7.0.2-1-64bit.msi" "/quiet";
remove-item "~\Desktop\Suricata 7.0.2-64bit IDS-IPS.lnk";
"<agent_config>

<localfile>
  <log_format>json</log_format>
  <location>C:/Program Files/Suricata/log/eve.json</location>
</localfile>

<!-- Shared agent configuration here -->

</agent_config>" >> "C:\Program Files (x86)\ossec-agent\shared\agent.conf"

#Suricata als Service installieren
suricata.exe -c suricata.yaml -i Eth0 -l ./log -knone -vvv --service-install
#Suricata Service Automatisch starten
Set-Service -Name suricata -StartUpType Automatic
#Suricata Manuell Starten
net start suricata





