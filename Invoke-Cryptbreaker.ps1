# Need to add Type (once implemented) Param description
function Invoke-Cryptbreaker{
    <#
    .SYNOPSIS

        Function to interface to the Cryptbreaker API. Use the Action paramater to specify what API endpoint to hit.

    .DESCRIPTION

        Friendly wrapper to access much of the exposed Cryptbreaker API endpoints. Utilizes Invoke-RestMethod to perform actions.

    .PARAMETER Action

        Specifies the API Endpoint being used. If not specified you will be promoted.
        Possible value are:
            ListFiles - List Hash Files (/api/files)
            GetFileDetails - Get Detailed Information for Specified Hash File (/api/files/:fileID)
            ListJobs - List Hash Crack Jobs (/api/jobs)
            GetJobDetails - Get Detailed Information for Specified Hash Crack Job (/api/jobs/:jobID)
            GetJobStatus - Get Status for Specified Hash Crack Job (/api/jobs/:jobID/status)
            GetPricing - Refresh and Return the Current AWS EC2 best pricing options (/api/pricing)
            GetHashesForHashFile - Get the hashes associated with the specified Hash File (/api/files/:fileID/hashes)
            GetHashesForJob - Get the hashes associated with the specified Hash Crack Job (/api/jobs/:jobID/hashes)
            GetHashes - Get all hashes known to Cryptbreaker (/api/hashes)
            PauseJob - Pause the specified Hash Crack Job (/api/jobs/:jobID/pause)
            ResumeJob - Resume the specified Hash Crack Job (/api/jobs/:jobID/resume)
            DeleteJob - Delete the specified Hash Crack Job (/api/jobs/:jobID/delete)
            CheckHashes - Submits a list of hashes to Cryptbreaker and returns a list of which hashes have been cracked
                          with crack information (/api/hashes/check)
            UploadHashFile - Submits a file to Cryptbreaker (/api/files)
            UploadAndCrack - Submits a file to Cryptbreaker, returns already cracked hashes, and creates a new Hash Crack Job
                             for the newly uploaded file (/api/crack/file)
            CreateCrackJob - Submits a request for a new Hash Crack Job (/api/jobs)
            UpdateProfile - Updates the local profile storing your Cryptbreaker URL and API Key information

	.PARAMETER Url

        Specifies the url of the Cryptbreaker instance to use. If not specified you will be prompted
            - http(s) must be included
            - port is optional but required if running on a non-standard port

        ie: http://192.168.1.10:3000

    .PARAMETER ApiKey

        Specifies the ApiKey to use. If not specified, you will be prompted
        domain your user context specifies.

	.PARAMETER UploadFile
	
        Specifies the file to upload to Cryptbreaker. Required for UploadHashFile,and UploadAndCrack Actions.
        Optional for CheckHashes. If not specified you will be prompted

    .PARAMETER FileID
	
        Specifies the File to act on. Required for GetFileDetails, GetHashesForHashFile, and CreateCrackJob.
        If not specified you will be prompted

    .PARAMETER JobID
	
        Specifies the Job to act on. Required for GetJobDetails, GetJobStatus, GetHashesForJob, PauseJob, ResumeJob, and DeleteJob.
        If not specified you will be prompted

    .PARAMETER HashFile
	
        Specifies the HashFile to upload as either the absolute or relative path to the file. Required for the Upload* functions.
        If not specified you will be prompted


    .PARAMETER Hashes
	
        Specifies the Hash or Hashes to check against Cryptbreaker data. A single hash or comma seperated list of hashes to check. Required for the CheckHashes function.
        If not specified you will be prompted

    .PARAMETER Cracked
	
        Specifies that Crytpbreak should search for only Cracked hashes. Used in the GetHashes* functions.
        If not specified all hashes will be returned (cracked and uncracked).

    .PARAMETER InstanceType
	
        Specifies the Instance Type to crack with. Required for CreateCrackJob. Valid options are "p3_2xl","p3_8xl","p3_16xl".
        If not specified a "p3_2xl" instance will be used

    .PARAMETER AvailabilityZone
	
        Specifies the Availability Zone to to act on. Required for CreateCrackJob.
        If not specified the Availability Zone for the cheapest "p3_2xl" currently available will be used

    .PARAMETER Rate
	
        Specifies the current rate that you want to pay. Required for CreateCrackJob. $0.25 may be added to increase liklihood of spot fulfillment
        If not specified the Rate for the cheapest "p3_2xl" currently available will be used

    .PARAMETER BruteForceLimit
	
        Specifies the maximum number of characters to attempt to brute force during cracking. O is used to disable brute forcing entirely. Required for CreateCrackJob.
        If not specified brute forcing will be disabled for non-LM hashes (I do not recommend going past 7 characters)

    .PARAMETER RedactionNone
	
        Specifies that no redaction will occur on plaintext credentials prior to being sent from the cracking instance to the Cryptbreaker instance.
        This is the default level of redaction that will occur unless otherwise specified

    .PARAMETER RedactionCharacter
	
        Specifies that character substitution will occur on plaintext credentials prior to being sent from the cracking instance to the Cryptbreaker instance.
        IE: Summer2019! -> Ulllll0000*

    .PARAMETER RedactionLength
	
        Specifies that full substitution will occur on plaintext credentials prior to being sent from the cracking instance to the Cryptbreaker instance.
        IE: Summer2019! -> ***********

    .PARAMETER RedactionFull
	
        Specifies that plaintext credentials will not be sent back to Cryptbreaker.
        IE: Summer2019! -> cracked

    .PARAMETER NoProfilePrompt
	
        Disable Prompt to save connection info to profile

    .EXAMPLE

        PS C:\> Invoke-Cryptbreaker

        Enters menu based prompts to interface to Cryptbreaker API.

    .EXAMPLE
        
        PS C:\> Invoke-Cryptbreaker -Action ListFiles -Url https://cryptbreaker.io
    
        Will prompt for API key then return a listing of files from the Cryptbreaker instance located at https://cryptbreaker.io

    .EXAMPLE

        PS C:\> Invoke-Cryptbreaker -Action UploadAndCrack -Url https://cryptbreaker.io -ApiKey 02d9dbcb-5c32-4927-aa9a-547903ff5d6c -UploadFile ./fileForCryptbreaker.txt

        Uploads the specified file to Cryptbreaker running at the specified URL using the provided ApiKey.
        Returns already cracked hashes, and the newly created FileID and JobID from Cryptbreaker.

    .EXAMPLE

        PS C:\> Invoke-Cryptbreaker -Action CreateCrackJob -Url https://cryptbreaker.io -ApiKey 02d9dbcb-5c32-4927-aa9a-547903ff5d6c -FileID K3rMMhdnNb7QheW3h -BruteForceLimit 0 -RedactionNone

        Start a Hash Crack Job for the Hash File in Cryptbreaker with the specified File ID. 
        The cheapest available p3_2xl instance will be used. Brute Force cracking is disabled and no redaction of plaintext will occur.
        Returns the newly created Hash Crack Job ID.

    .EXAMPLE

        PS C:\> Invoke-Cryptbreaker -Action CheckHashes -Hashes "31D6CFE0D16AE931B73C59D7E0C089C0,66e749cce44c865633cab65da26ae8c7,c5944599a60347d792d05b93956e161b"

        Sends the list of Hashes specified to Cryptbreaker and returns information for any cracked hashes.

        _id               data                             meta        
        ---               ----                             ----        
        MfJhd64nQ89ySkmKN 31D6CFE0D16AE931B73C59D7E0C089C0 @{type=NTLM}
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("ListFiles","GetFileDetails","ListJobs","GetJobDetails","GetJobStatus","GetPricing","GetHashesForHashFile","GetHashesForJob","GetHashes","PauseJob","ResumeJob","DeleteJob","CheckHashes","UploadHashFile","UploadAndCrack","CreateCrackJob","UpdateProfile")]
        [String]
        $Action,

        [String]
        $Url,

		[String]
        $ApiKey,

		[String]
        $UploadFile,
        
        [String]
        $FileID,
        
        [String]
        $JobID,
        
        [String]
        $InstanceType,
        
        [String]
        $AvailabilityZone,            

        [String]
        $Rate,

        # Want to eventually add Type to allow filtering on searches (ie: GetHashesForFile -Cracked -Type NTLM)
        #[String]
        #$Type,

        [String]
        $Hashes,

        [String]
        $HashFile,

        [String]
        $BruteForceLimit,
        
        [Switch]
        $RedactionNone,  

        [Switch]
        $RedactionCharacter,

        [Switch]
        $RedactionLength,

        [Switch]
        $RedactionFull,

        [Switch]
        $Cracked,

        [Switch]
        $NoProfilePrompt
    )
    $requireFile = "CheckHashes","UploadHashFile","UploadAndCrack"
    $requireJobID = "GetJobDetails","GetJobStatus","GetHashesForJob","PauseJob","ResumeJob","DeleteJob"
    $requireFileID = "GetFileDetails","GetHashesForHashFile","CreateCrackJob"

    if($Action -eq "UpdateProfile"){
        if(Test-Path $HOME\.cryptbreaker){
            Remove-Item $HOME\.cryptbreaker
        }
        while($Url.Length -le 0){
            $Url = Read-Host -Prompt "`nPlease enter the Cryptbreaker url`n`tInclude http(s):// and port info if on a non-standard port`n`tie: http://192.168.1.12:3000`n`nUrl"
        }
        while($ApiKey.Length -le 0){
            $ApiKey = Read-Host -Prompt "`nPlease enter the Cryptbreaker API Key"
        }
        $response = Read-Host -Prompt "Would you like to save the ApiKey/Url information in your profile for next time?`n`tURL: $Url`n`tAPI Key:$ApiKey`n`n[Yn]"
        if($response.ToString().ToLower() -eq "y" -or $response.ToString().Length -le 0){
            $profileProps = @{
                Url = $Url
                ApiKey = $ApiKey
            }
            $profileObj = New-Object psobject -Property $profileObj
            $profileObj | ConvertTo-Json | Out-File -Encoding ascii -FilePath $HOME\.cryptbreaker
            Write-Output "Profile Saved"

        } else {
            return
        }
    }


    $profile = ""
    # attempt to load profile...
    if(Test-Path $HOME\.cryptbreaker){
        $profile = (cat $HOME\.cryptbreaker | ConvertFrom-Json)
        #if there's a profile then we just use that...
        $Url = $profile.Url
        $ApiKey = $profile.ApiKey
    } else {
        while($Url.Length -le 0){
            $Url = Read-Host -Prompt "`nPlease enter the Cryptbreaker url`n`tInclude http(s):// and port info if on a non-standard port`n`tie: http://192.168.1.12:3000`n`nUrl"
        }
        while($ApiKey.Length -le 0){
            $ApiKey = Read-Host -Prompt "`nPlease enter the Cryptbreaker API Key"
        }
        if(-not $NoProfilePrompt){
            $response = Read-Host -Prompt "Would you like to save the ApiKey/Url information in your profile for next time?`n`tURL: $Url`n`tAPI Key:$ApiKey`n`n[Yn]"
            if($response.ToString().ToLower() -eq "y" -or $response.ToString().Length -le 0){
                $profileProps = @{
                    Url = $url
                    ApiKey = $key
                }
                $profileObj = New-Object psobject -Property $profileObj
                $profileObj | ConvertTo-Json | Out-File -Encoding ascii -FilePath $HOME\.cryptbreaker
                Write-Output "Profile Saved"
            }
        }        
    }

    # now we do actions
    if($Action -eq "ListFiles"){
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)

        $response = Invoke-RestMethod "$Url/api/files" -Method 'GET' -Headers $headers
        $response.hashFiles
    }

    if($Action -eq "GetFileDetails"){
        while($FileID.Length -le 0){
            $FileID = Read-Host -Prompt "Please enter a FileID to get details for"
        }
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)
        
        $response = Invoke-RestMethod "$Url/api/files/$fileID" -Method 'GET' -Headers $headers 
        $response
    }

    if($Action -eq "ListJobs"){
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)
        $response = Invoke-RestMethod "$Url/api/jobs" -Method 'GET' -Headers $headers
        $response.crackJobs
    }
    
    if($Action -eq "GetJobDetails"){
        while($JobID.Length -le 0){
            $JobID = Read-Host -Prompt "Please enter a JobID to get details for"
        }
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)
        
        $response = Invoke-RestMethod "$Url/api/jobs/$JobID" -Method 'GET' -Headers $headers 
        $response
    }

    if($Action -eq "GetJobStatus"){
        while($JobID.Length -le 0){
            $JobID = Read-Host -Prompt "Please enter a JobID to get details for"
        }
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)
        
        $response = Invoke-RestMethod "$Url/api/jobs/$JobID/status" -Method 'GET' -Headers $headers 
        $response
    }

    if($Action -eq "GetPricing"){
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)
        
        $response = Invoke-RestMethod "$Url/api/pricing" -Method 'GET' -Headers $headers 
        $response
    }

    if($Action -eq "GetHashesForHashFile"){
        while($FileID.Length -le 0){
            $FileID = Read-Host -Prompt "Please enter a FileID to get hashes for"
        }
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)
        $response = ""
        if($Cracked){
            $response = Invoke-RestMethod "$Url/api/files/$fileID/hashes?cracked=true" -Method 'GET' -Headers $headers 
        } else {
            $response = Invoke-RestMethod "$Url/api/files/$fileID/hashes" -Method 'GET' -Headers $headers 
        }
        $response
    }
    
    if($Action -eq "GetHashesForJob"){
        while($JobID.Length -le 0){
            $JobID = Read-Host -Prompt "Please enter a JobID to get details for"
        }
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)
        $response = ""
        if($Cracked){
            $response = Invoke-RestMethod "$Url/api/jobs/$jobID/hashes?cracked=true" -Method 'GET' -Headers $headers 
        } else {
            $response = Invoke-RestMethod "$Url/api/jobs/$jobID/hashes" -Method 'GET' -Headers $headers 
        }
        $response
    }

    if($Action -eq "GetHashes"){
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)
        $response = ""
        if($Cracked){
            $response = Invoke-RestMethod "$Url/api/hashes?cracked=true" -Method 'GET' -Headers $headers 
        } else {
            $response = Invoke-RestMethod "$Url/api/hashes" -Method 'GET' -Headers $headers 
        }
        $response
    }
    
    if($Action -eq "PauseJob"){
        while($JobID.Length -le 0){
            $JobID = Read-Host -Prompt "Please enter a JobID to get pause"
        }
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)
        
        $response = Invoke-RestMethod "$Url/api/jobs/$JobID/pause" -Method 'GET' -Headers $headers 
        $response
    }

    if($Action -eq "ResumeJob"){
        while($JobID.Length -le 0){
            $JobID = Read-Host -Prompt "Please enter a JobID to resume"
        }
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)
        
        $response = Invoke-RestMethod "$Url/api/jobs/$JobID/resume" -Method 'GET' -Headers $headers 
        $response
    }

    if($Action -eq "DeleteJob"){
        while($JobID.Length -le 0){
            $JobID = Read-Host -Prompt "Please enter a JobID to delete"
        }
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Apikey", $ApiKey)
        
        $response = Invoke-RestMethod "$Url/api/jobs/$JobID/delete" -Method 'GET' -Headers $headers 
        $response
    }

    if($Action -eq "CheckHashes"){
        while($Hashes.Length -le 0){
            $Hashes = Read-Host -Prompt "Please enter a hash or comma seperated list of hashes to check"
        }
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Apikey", $ApiKey)
        $hashJoinedContent =  ($Hashes.Split(",")) -Join "`",`""
        $body = "{`"hashes`":[`"$hashJoinedContent`"]}"
        $response = Invoke-RestMethod "$Url/api/hashes/check" -Method 'POST' -Headers $headers -Body $body
        $response
    }

    if($Action -eq "UploadHashFile"){
        if($HashFile.Length -gt 0){
            if((Test-Path $HashFile) -eq $false){
                        $HashFile = ""
            }
        }
        while($HashFile.Length -le 0){
            $HashFile = Read-Host -Prompt "Please enter the path to the hash file to upload"
            if((Test-Path $HashFile) -eq $false){
                $HashFile = ""
            }
        }
        $fullPath = (Resolve-Path $HashFile).Path
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Apikey", $ApiKey)
        $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($fullPath))
        $fileName = [System.IO.Path]::GetFileName($fullPath)
        $body = "{`"fileName`":`"$fileName`",`"fileData`":`"$base64String`"}"
        $response = Invoke-RestMethod "$Url/api/files/" -Method 'POST' -Headers $headers -Body $body
        $response
    }

    if($Action -eq "UploadAndCrack"){
        if($HashFile.Length -gt 0){
            if((Test-Path $HashFile) -eq $false){
                        $HashFile = ""
            }
        }
        while($HashFile.Length -le 0){
            $HashFile = Read-Host -Prompt "Please enter the path to the hash file to upload and crack"
            if((Test-Path $HashFile) -eq $false){
                $HashFile = ""
            }
        }
        $fullPath = (Resolve-Path $HashFile).Path
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Apikey", $ApiKey)
        $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($fullPath))
        $fileName = [System.IO.Path]::GetFileName($fullPath)
        $body = "{`"fileName`":`"$fileName`",`"fileData`":`"$base64String`"}"
        $response = Invoke-RestMethod "$Url/api/crack/file/" -Method 'POST' -Headers $headers -Body $body
        $response
    }
    
    if($Action -eq "CreateCrackJob"){
        # Setting up a crack job requires:
        ## FileID, Rate, InstanceType AvailabilityZone
        # Allows for user to specify
        ## , RedactionNone, RedactionCharacter, RedactionLength, RedactionFull, BruteForceLimit
        while($FileID.Length -le 0){
            $FileID = Read-Host -Prompt "Please enter a FileID to get hashes for"
        }
        while($Rate.Length -le 0){
            $Rate = Read-Host -Prompt "Please enter a Rate to submit your spot request for"
        }
        while($InstanceType.Length -le 0){
            $InstanceType = Read-Host -Prompt "Please enter an InstanceType to utilize (p3_2xl, p3_8xl, p3_16xl)"
        }
        while($AvailabilityZone.Length -le 0){
            $AvailabilityZone = Read-Host -Prompt "Please enter an AvailabilityZone to get hashes for"
        }
        $maskingOptionContent = "{`"redactionNone`":true,`"redactionCharacter`":false,`"redactionLength`":false,`"redactionFull`":false}"
        if($RedactionCharacter){
            $maskingOptionContent = "{`"redactionNone`":false,`"redactionCharacter`":true,`"redactionLength`":false,`"redactionFull`":false}"
        }
        if($RedactionLength){
            $maskingOptionContent = "{`"redactionNone`":false,`"redactionCharacter`":false,`"redactionLength`":true,`"redactionFull`":false}"
        }
        if($RedactionFull){
            $maskingOptionContent = "{`"redactionNone`":false,`"redactionCharacter`":false,`"redactionLength`":false,`"redactionFull`":true}"
        }

        $bruteLimit = "0"
        if($BruteForceLimit){
            $bruteLimit = $BruteForceLimit
        }

       
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Apikey", $ApiKey)
       
        $body = "{`"ids`":[`"$FileID`"],`"duration`":1,`"instanceType`":`"$InstanceType`",`"availabilityZone`":`"$AvailabilityZone`",`"rate`":`"$Rate`",`"makingOption`":$maskingOptionContent,`"useDictionaries`":true,`"bruteLimit`":`"$bruteLimit`"}"
        $response = Invoke-RestMethod "$Url/api/jobs/" -Method 'POST' -Headers $headers -Body $body
        $response
    }
    
}