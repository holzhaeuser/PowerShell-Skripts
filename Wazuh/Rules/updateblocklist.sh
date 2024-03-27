# URL der Eingabeliste
input_url="https://raw.githubusercontent.com/dmachard/blocklist-domains/data/blocklist.txt"
targetdir="/var/ossec/etc/lists/"
temp_input_file="blocklist_temp"
output_file="blocklist_extended"

if command -v curl &>/dev/null; then
    curl -sS "$input_url" > "$temp_input_file"
elif command -v wget &>/dev/null; then
    wget -qO "$temp_input_file" "$input_url"
else
    echo "Fehler: curl oder wget nicht gefunden. Installieren Sie eines der Programme, um fortzufahren."
    exit 1
fi

if [ ! -f "$temp_input_file" ]; then
    echo "Fehler: Eingabeliste konnte nicht heruntergeladen werden."
    exit 1
fi

sed -i '/^#/d' "$temp_input_file"

while IFS= read -r url; do
    
    if [ -z "$url" ]; then
        continue
    fi

    adjusted_url="${url}:" 

    echo "$adjusted_url" >> "$output_file"
done < "$temp_input_file"

rm -f "$temp_input_file"
mv -f "$output_file" "$targetdir" && echo "Update erfolgreich: '$output_file' wurde in das Zielverzeichnis '$targetdir' verschoben."
service wazuh-manager restart && echo "Wazuh-Manager wurde neugestartet"


