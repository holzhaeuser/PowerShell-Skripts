#!/bin/bash

file="/var/ossec/etc/ossec.conf"

search_string="<use_source_ip>no</use_source_ip>"

# Werte bitte anpassen, zum Testen habe ich jeweils 10 min verwendet
insert_values=(
    '    <force>'
    '     <enabled>yes</enabled>'
    '     <disconnected_time enabled="yes">10m</disconnected_time>'
    '     <after_registration_time>10m</after_registration_time>'
    '     <key_mismatch>yes</key_mismatch>'
    '    </force>'
    '    <force_insert>yes</force_insert>'
    '    <force_time>0</force_time>'
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

echo "Änderungen in $file wurden erfolgreich vorgenommen."
