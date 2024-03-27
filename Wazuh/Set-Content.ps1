try {
    $FileName = "C:\Users\mm\Desktop\agent.conf"
    $Patern = "<!-- Shared agent configuration here -->" # the 2 lines will be added just after this pattern 
    $FileOriginal = Get-Content $FileName
    Write-Host $Patern
    <# create empty Array and use it as a modified file... #>
    
    $FileModified = @() 
    
    Foreach ($Line in $FileOriginal)
    {    
        $FileModified += $Line
    
        if ($Line -match $patern) 
        {
        #Add Lines after the selected pattern 
        $FileModified += ''
        $FileModified += '<localfile>'
        $FileModified += ' <log_format>json</log_format>'
        $FileModified += ' <location>C:/Program Files/Suricata/log/eve.json</location>'
        $FileModified += '</localfile>'
        $FileModified += ''
        } 
    }
    Set-Content $fileName $FileModified
} catch { "Fehler: $_" }