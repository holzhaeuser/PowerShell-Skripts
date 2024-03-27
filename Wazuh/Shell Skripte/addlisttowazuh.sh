#!/bin/bash

file="/var/ossec/etc/ossec.conf"

search_string="<list>etc/lists/security-eventchannel</list>"

# Werte bitte anpassen, zum Testen habe ich jeweils 10 min verwendet
insert_values=(
    '    <list>etc/lists/blocklist_extended</list>'
)


tmp_file=$(mktemp)


while IFS= read -r line; do
    echo "$line" >> "$tmp_file"
    if [[ $line == *"$search_string"* ]]; then
        # Füge die Werte ein
        for value in "${insert_values[@]}"; do
            echo "$value" >> "$tmp_file"
        done
    fi
done < "$file"


cp "$tmp_file" "$file"

rm "$tmp_file"

echo "Änderungen in $file wurden erfolgreich vorgenommen." &&
service wazuh-manager restart && echo "Wazuh-Manager wurde neugestartet"
