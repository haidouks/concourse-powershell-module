# Implement your module commands in this script.
$Script:flyPath=""
function Set-FlyPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$path
    )

    begin {
    }

    process {
        $Script:flyPath = $path
    }

    end {
    }
}

function Get-FlyCLI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   HelpMessage="Download Path for Fly")]
        [ValidateNotNullOrEmpty()]
        [string]
        $path,
        [Parameter(Mandatory=$true,
                   HelpMessage="URL of FLY Executable")]
        [String]
        $url
    )

    begin {
    }

    process {
        Write-Verbose -Message "Downloading FLY from $Url to $Path"
        $progressPreference = 'silentlyContinue'
        try {
            Invoke-WebRequest -Uri $Url -OutFile $Path -ErrorVariable errorDetails -NoProxy
            Set-FlyPath -Path $path
            if($IsLinux) {
                chmod +x $path
            }
        }
        catch {
            $errorMessage = "$($_.Exception.Message)`n$(($_ | Select-Object -ExpandProperty invocationinfo).PositionMessage)`nerrorDetails:`n$errorDetails"
            throw "Catched an exception in Function:$($MyInvocation.MyCommand)`n$errorMessage"
        }
    }
    end {
    }
}

function Register-Concourse {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [String]
        $concourseUrl,
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$cred
    )

    begin {

        Write-Verbose -Message "Setting fly path $Script:flyPath"
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
        $userName = $cred.UserName
        $password = $cred.GetNetworkCredential().password
    }

    process {

        try {

            $login = Invoke-Fly -t devops login -c $concourseUrl -k -u $username -p $password 2>&1
            if(($login | out-string) -match "target saved") {
                Write-Verbose -Message "Login is successfull"
            }
            else {
                $errorMessage = "$($login | out-string)`n$(($_ | Select-Object -ExpandProperty invocationinfo).PositionMessage)"
                throw $errorMessage
            }

        }
        catch {
            $errorMessage = "$($_.Exception.Message)`n$(($_ | Select-Object -ExpandProperty invocationinfo).PositionMessage)"
            throw "Catched an exception in Function:$($MyInvocation.MyCommand)`n$errorMessage"
        }

    }

    end {
    }
}


function Get-ConcoursePipelines {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [string]
        $pipelineName
    )
    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
        $pipelines = Invoke-Fly -t devops pipelines --json 2>&1
        if(-not $?) {
          $errorMessage = "$($pipelines | out-string)`n$(($_ | Select-Object -ExpandProperty invocationinfo).PositionMessage)"
          throw $errorMessage
        }
    }

    process {
        if (-not [string]::IsNullOrEmpty($pipelineName) ){
            $pipelines = $($pipelines | ConvertFrom-Json) | Where-Object{$_.name -eq $pipelineName} | ConvertTo-Json
        }
        return $pipelines

    }

    end {
    }
}


function Invoke-ConcourseJob {
    [CmdletBinding()]
    param (
        # Pipeline name
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $pipeline,
        # Pipeline's job name
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $job,
        [switch]
        $watch
    )

    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
    }

    process {
        if ($watch) {
            return Invoke-Fly -t devops trigger-job -j $pipeline/$job -w 2>&1
        }
        else {
            $result = Invoke-Fly -t devops trigger-job -j $pipeline/$job 2>&1
            if ($?) {
                return @{
                    State = $result.Split(" ")[0]
                    Job = $job
                    Pipeline = $pipeline
                    Id = $result.Split(" ")[2]
                }
            }
            else {
                $errorMessage = "$($result | out-string)`n$(($_ | Select-Object -ExpandProperty invocationinfo).PositionMessage)"
                throw "Catched an exception in Function:$($MyInvocation.MyCommand)`n$errorMessage"
            }
        }
    }

    end {
    }
}

function Get-ConcourseJobStatus {
    [CmdletBinding()]
    param (
        # Pipeline name
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $pipeline,
        # Pipeline's job name
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $job,
        # Job's build id
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int]
        $build,
        [int]
        $last=100

    )

    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
    }

    process {
        $jobStatus = Invoke-Fly -t devops builds -a -c $last -j $pipeline/$job --json 2>&1
        if ($?) {
            return $($jobStatus | ConvertFrom-Json) | Where-Object {$_.name -eq $build}
        }
        else {
            $errorMessage = "$($jobStatus | out-string)`n$(($_ | Select-Object -ExpandProperty invocationinfo).PositionMessage)"
            throw "Catched an exception in Function:$($MyInvocation.MyCommand)`n$errorMessage"
        }
    }

    end {
    }
}

function Test-ConcourseLoginStatus {
    [CmdletBinding()]
    param (

    )

    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
    }

    process {
        $result = Invoke-Fly -t devops status 2>&1
        if ($result -match "logged in") {
            return $true
        }
        else {
            return $false
        }
    }

    end {
    }
}

function Get-ConcourseJobLog {
    [CmdletBinding()]
    param (
        # Pipeline name
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $pipeline,
        # Pipeline's job name
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $job,
        # Job's build id
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int]
        $build
    )

    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
    }

    process {
        $result = Invoke-Fly -t devops watch -j $pipeline/$job -b $build -t 2>&1
        if(-not $?)
        {
            $errorMessage = "$($result | out-string)`n$(($_ | Select-Object -ExpandProperty invocationinfo).PositionMessage)"
            throw "Catched an exception in Function:$($MyInvocation.MyCommand)`n$errorMessage"
        }
        return $result
    }

    end {
    }
}
function Get-ConcourseBuilds {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$false)]
        $query,
        # Parameter help description
        [Parameter(Mandatory=$false)]
        [int]
        $since=30,
        # Parameter help description
        [Parameter(Mandatory=$false)]
        [int]
        $count=1000
    )
    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
        $date=(Get-Date).AddMinutes(-$since).ToString("yyyy-MM-dd HH:mm:ss")
        $builds = Invoke-Fly -t devops builds --since $date -c $count --json 2>&1
        if(-not $?) {
          $errorMessage = "$($builds | out-string)`n$(($_ | Select-Object -ExpandProperty invocationinfo).PositionMessage)"
          throw $errorMessage
        }
    }

    process {

        Write-Verbose "hash: $($query | ConvertTo-Json)"
        $builds = $builds | ConvertFrom-Json
        foreach($key in $query.Keys) {
            Write-Verbose "filtering for key : $key and value : $query['$key']"
            $builds = $builds | Where-Object{$_."$key" -eq $query["$key"]}
        }

        return $builds | ConvertTo-Json -Compress

    }

    end {
    }
}

function Get-ConcourseWorkers {
    [CmdletBinding()]
    param ()
    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath

        $workers = Invoke-Fly -t devops workers --json 2>&1
        if(-not $?) {
          $errorMessage = "$($workers | out-string)`n$(($_ | Select-Object -ExpandProperty invocationinfo).PositionMessage)"
          throw $errorMessage
        }
    }

    process {
        return $workers
    }

    end {
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
