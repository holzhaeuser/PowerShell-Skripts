# Erstelle Backup Verzeichnis
bkp_folder=~/wazuh_files_backup/$(date +%F_%H:%M)
mkdir -p $bkp_folder && echo $bkp_folder
# Host Informationen sichern
cat /etc/*release* > $bkp_folder/host-info.txt
echo -e "\n$(hostname): $(hostname -I)" >> $bkp_folder/host-info.txt
# Sichere alle Serverdaten
rsync -aREz \
/etc/filebeat/ \
/etc/postfix/ \
/var/ossec/api/configuration/ \
/var/ossec/etc/client.keys \
/var/ossec/etc/sslmanager* \
/var/ossec/etc/ossec.conf \
/var/ossec/etc/internal_options.conf \
/var/ossec/etc/local_internal_options.conf \
/var/ossec/etc/rules/local_rules.xml \
/var/ossec/etc/decoders/local_decoder.xml \
/var/ossec/etc/shared/ \
/var/ossec/logs/ \
/var/ossec/queue/agentless/ \
/var/ossec/queue/agents-timestamp \
/var/ossec/queue/fts/ \
/var/ossec/queue/rids/ \
/var/ossec/stats/ \
/var/ossec/var/multigroups/ $bkp_folder
# Sichere Zertifikate
rsync -aREz \
/var/ossec/etc/*.pem \
/var/ossec/etc/authd.pass $bkp_folder
# Sichere selbst erstellte Daten (z.b. listen)
rsync -aREz \
/var/ossec/active-response/bin/<custom_AR_script> \
/var/ossec/etc/lists/<user_cdb_list>.cdb \
/var/ossec/integrations/<custom_integration_script> \
/var/ossec/wodles/<custom_wodle_script> $bkp_folder
# Datenbank sichern
rsync -aREz \
/var/ossec/queue/db/ $bkp_folder
# Sichere Indexer und Dashboard
rsync -aREz \
/etc/wazuh-indexer/certs/ \
/etc/wazuh-indexer/jvm.options \
/etc/wazuh-indexer/jvm.options.d \
/etc/wazuh-indexer/log4j2.properties \
/etc/wazuh-indexer/opensearch.yml \
/etc/wazuh-indexer/opensearch.keystore \
/etc/wazuh-indexer/opensearch-observability/ \
/etc/wazuh-indexer/opensearch-reports-scheduler/ \
/etc/wazuh-indexer/opensearch-security/ \
/usr/lib/sysctl.d/wazuh-indexer.conf $bkp_folder
# Sichere Wazuh-Dashboard Zertifikate
rsync -aREz \
/etc/wazuh-dashboard/certs/ \
/etc/wazuh-dashboard/opensearch_dashboards.yml \
/usr/share/wazuh-dashboard/config/opensearch_dashboards.keystore \
/usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml $bkp_folder
# Falls vorhanden: sichere runtergeladene Inhalte
rsync -aREz \
/usr/share/wazuh-dashboard/data/wazuh/downloads/ \
/usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom/images/ $bkp_folder
