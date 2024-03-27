0 0 * * mon find /var/ossec/logs/alerts/ -type f -mtime +365 -exec rm -f {} ; # Löscht 1 Jahr alte Alerts
0 0 * * mon find /var/ossec/logs/archives/ -type f -mtime +365 -exec rm -f {} ; # Löscht aus dem Archiv Dateien die Älter als 1 Jahr sind



# Lösche Agents die Älter als 730 Tage sind

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

set -e

MAX_AGE=17280h

AUTHORIZATION=$(curl -u $1:$2-k -X GET "https://localhost:55000/security/user/authenticate?raw=true")

curl -k -X DELETE "https://localhost:55000/agents?status=pending,never_connected,disconnected&older_than=${MAX_AGE}&agents_list=all&wait_for_complete=true&purge=true" -H "Authorization: Bearer ${AUTHORIZATION}"