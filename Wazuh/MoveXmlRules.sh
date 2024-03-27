#!/bin/bash
cp -f local_rules.xml /var/ossec/etc/rules/ &&
cp -f 0840-win_event_channel.xml /var/ossec/ruleset/rules/ &&
cp -f 0015-ossec_rules.xml /var/ossec/ruleset/rules/ &&
cp -f 0475-suricata_rules.xml /var/ossec/ruleset/rules/ &&
cp -f 0570-sca_rules.xml /var/ossec/ruleset/rules/ &&
cp -f 0580-win-security_rules.xml /var/ossec/ruleset/rules/ &&
cp -f 0590-win-system_rules.xml /var/ossec/ruleset/rules/ &&
cp -f 0600-win-wdefender_rules.xml /var/ossec/ruleset/rules/ &&
cp -f 0602-win-wfirewall_rules.xml /var/ossec/ruleset/rules/ &&
cp -f 0595-win-sysmon_rules.xml /var/ossec/ruleset/rules/ &&
service wazuh-manager restart