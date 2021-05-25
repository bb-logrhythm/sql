# Source: Kyle Speck

$SQLquery=’#put query here’

$result=invoke-sqlcmd -query $SQLquery -database LogRhythmEMDB

$Extension = get-date -Format 'yyyyMMdd'

$FileName = 'c:\tmp\Outputv1' + '_' + $Extension + '.csv'

$result |export-csv $FileName -notypeinformation

#set the step type to Powershell