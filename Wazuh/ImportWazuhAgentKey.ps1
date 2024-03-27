if ($env:computername -eq 'PC001') {
    $key = 'MDAxIFBDMDAxIGFueSA3NjY5M2Y5YmZkM2U5MTQ3ZmU1NTNkZTkxNmRiNGNjNTIyYWRhZGI5M2QwNTFiMzE2OTg5OWVlZWQxZjljMmQ1'
    & "C:\Program Files (x86)\ossec-agent\manage_agents.exe" -i $key
    Restart-Service Wazuh
}
if ($env:computername -eq 'PC002') {
    $key = 'MDAyIFBDMDAyIGFueSBmYWIwMDEyZGI0Y2U2YTU4NWYyYWY2NjgzMzhlODkwYjRhMjczYWRmODZkZmZiZGYxZjc5M2Q4NzA5ZTA5ZWVi'
    & "C:\Program Files (x86)\ossec-agent\manage_agents.exe" -i $key
    Restart-Service Wazuh
}