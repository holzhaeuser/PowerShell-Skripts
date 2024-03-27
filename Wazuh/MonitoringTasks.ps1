$GetTask = $((Get-Process).ProcessName)
foreach ($Task in $GetTask) {


Write-Host "Tasklist: $Task"
}

<!-- Prozesse Monitoren -->
  <wodle name="command">
    <disabled>no</disabled>
    <tag>tasklist</tag>
    <command>powershell.exe C:\TesteTasklist.ps1</command>
    <interval>2m</interval>
    <run_on_start>yes</run_on_start>
    <timeout>10</timeout>
  </wodle>