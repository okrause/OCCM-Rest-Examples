# Example how to do API calls to Netapp OnCommand Cloud Manager
# OCCM API documentation (Swagger) at http://<occm-ip>/occm/api-doc
# No error handling here.
# How to do error handling: https://zeleskitech.com/2016/09/23/making-better-rest-calls-powershell/

$server = '<<http://your_occm_ip>>'
$ctype = 'application/json'
$session=new-object microsoft.powershell.commands.webrequestsession

# How ot login to OCCM
$credentials = (Get-Content "credentials.json")
$r = Invoke-RestMethod -Uri "$server/occm/api/auth/login" -Method Post -Body $credentials -ContentType $ctype -WebSession $session

# POST requests
## create OTC working environment
$otc = (Get-Content "otc.json")
$r = Invoke-RestMethod -Uri "$server/occm/api/vsa/working-environments" -Method Post -Body $otc -ContentType $ctype -WebSession $session

$otcid = $r.publicID

# How to do GET requests
## show working environments
$r = Invoke-RestMethod -Uri "$server/occm/api/vsa/working-environments" -Method Get -ContentType $ctype -WebSession $session
$r

## check if environment is ready
# status = (ON|OFF|DELETING|INITIALIZING)
do
{
    Start-Sleep -s 5
    $r = Invoke-RestMethod -Uri "$server/occm/api/vsa/working-environments/$otcid\?fields=status,svmName" -Method Get -ContentType $ctype -WebSession $session
    Write-Output $r.status.status
} until ($r.status.status -eq "ON")

Write-Output "Cluster: $($r.name), SVM: $($r.svmName) is up an running."

# How to do DELETE request
## delete OTC instance
$r = Invoke-RestMethod -Uri "$server/occm/api/vsa/working-environments/$otcid" -Method Delete -ContentType $ctype -WebSession $session
