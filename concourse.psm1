# Implement your module commands in this script.
$Script:flyPath = ""
$Script:alias = ""
function Invoke-ConcourseAuth {
    [OutputType([System.Collections.ArrayList])]
    param (
        # Username
        [ValidateNotNullOrEmpty()]
        [String]
        $user,
        # Password
        [ValidateNotNullOrEmpty()]
        [String]
        $pass,
        # Concourse Base Url
        [ValidateNotNullOrEmpty()]
        [String]
        $concourseUrl,
        # Login Type
        [ValidateSet("local","ldap")]
        [ValidateNotNullOrEmpty()]
        [String]
        $loginType
    )
    try {
        $linkToLogin = "/sky/issuer/auth/$loginType"
        $req = Invoke-WebRequest -Uri "$concourseUrl/sky/login" -Method Get -SessionVariable ciCookie -SkipCertificateCheck
        $newUri = $req.Links.href | Where-Object {$_ -match $linkToLogin}
        $null = Invoke-RestMethod -Uri "$concourseUrl$newUri" -WebSession $ciCookie -Method Post -FollowRelLink -Body @{login=$user;password=$pass} -SkipCertificateCheck
        $cookies = $ciCookie.Cookies.GetCookies($concourseUrl)
        $cookies["skymarshal_auth0"] ? $(return $cookies) : $(Throw "Unable to authenticate to $concourseUrl with user $user and login type $loginType")
    }
    catch {
        $exception = $PSItem | Select-Object * | Format-Custom -Depth 1 | Out-String
        Throw $exception
    }
    <#
        .SYNOPSIS

        Returns cookies to login Concourse.

        .DESCRIPTION

        Logins to Concourse and receives. These cookies can be used to call services on Concourse API.

        .PARAMETER User
        Username of the user.

        .PARAMETER Pass
        Password of the user.

        .PARAMETER concourseUrl
        Specifies the base url of Concourse.

        .PARAMETER loginType

        Login method for Concourse. Validation set is "local" or "ldap".


        .INPUTS

        None.

        .OUTPUTS

        System.String. Invoke-ConcourseAuth returns cookies in an array list.


        .EXAMPLE

        PS> Invoke-ConcourseAuth -user "myUser" -pass "myPass" -concourseUrl "http://myConcourseUrl.com" -loginType "local"

        Comment    :
        CommentUri :
        HttpOnly   : True
        Discard    : False
        Domain     : myConcourseUrl.com
        Expired    : False
        Expires    : 03.09.2020 10:53:19
        Name       : skymarshal_auth0
        Path       : /
        Port       :
        Secure     : False
        TimeStamp  : 02.09.2020 10:53:20
        Value      : "bearer 1239182319273198hasdklasd0v1lkj1.eyJpc3MiOiJodHRwOi8vY2kudG9vbC56ZnUuemIvc2t5L2lzc3VlciIsInN1YiI6IkNlkjasd09lk1234092lkndlsfs0d9fsdfklsdlfn2039rlkqa-aisadnVmhaRzFwYmhJRmJHOWpZV3c
                     iLCJhdWQiOiJjb25jb3Vyc2Utd2ViIiwiZXhwIjoxNTk5MTE5NjAwLCJpYXQiOjE1OTkwMzMyMDAsImF0X2hhc2giOiJvMkFSZHA4enE1c3JWNnEtUzZmeWZnIiwiZW1haWwiOiJhZG1pbiIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJmZWRlcmF0Z
                     WRfY2xhaW1zIjp7ImNvbm5lY3Rvcl9pZCI6ImxvY2FsIiwidXNlcl9pZCI6ImFkbWluIiwidXNlcl9uYW1lIjoiYWRtaW4ifX0.Bn9A_btzIWUw5IdYdEcSku5uEUfoTSBgyogYnjgAly99qEDVqK_3IWtMOThfHJSzMmcy17RYpR8ebW3cuk3OLgQ
                     KHfLLWzoZaLGSUWjG8bszAIbIDOBT7qMGbesEx01yKCOsFXUuhaqudt9f3iKrjjz3rCE9TOkhSKmCUH5NKgzzgW9iEPhrwWlMNtdmpWiF2nPp1G9DDzxfIOMMy6Pjf95-NzG5LSUQMY0inLAA_E2xAWozmRJRl78pRk7JvfU5WcEu9hboWwMbeXqUk
                     bgQq_puI6C_baQosWwzHtham32yz145h0r83LKLDkFXVhudfToAiwk4JrHUnxv-kmQ6rHaw"
        Version    : 0

        Comment    :
        CommentUri :
        HttpOnly   : True
        Discard    : False
        Domain     : myConcourseUrl.com
        Expired    : False
        Expires    : 03.09.2020 10:53:19
        Name       : skymarshal_csrf
        Path       : /
        Port       :
        Secure     : False
        TimeStamp  : 02.09.2020 10:53:20
        Value      : 8bc676b0d727bc01efd8f664cc8b4844700b556f6a54b9605b90b98f92bb8977
        Version    : 0

        .EXAMPLE

        PS> Invoke-ConcourseAuth -user "myUser" -pass "myPass" -concourseUrl "http://myConcourseUrl.com" -loginType "ldap"
        Comment    :
        CommentUri :
        HttpOnly   : True
        Discard    : False
        Domain     : myConcourseUrl.com
        Expired    : False
        Expires    : 03.09.2020 10:53:19
        Name       : skymarshal_auth0
        Path       : /
        Port       :
        Secure     : False
        TimeStamp  : 02.09.2020 10:53:20
        Value      : "bearer 1239182319273198hasdklasd0v1lkj1.eyJpc3MiOiJodHRwOi8vY2kudG9vbC56ZnUuemIvc2t5L2lzc3VlciIsInN1YiI6IkNlkjasd09lk1234092lkndlsfs0d9fsdfklsdlfn2039rlkqa-aisadnVmhaRzFwYmhJRmJHOWpZV3c
                     iLCJhdWQiOiJjb25jb3Vyc2Utd2ViIiwiZXhwIjoxNTk5MTE5NjAwLCJpYXQiOjE1OTkwMzMyMDAsImF0X2hhc2giOiJvMkFSZHA4enE1c3JWNnEtUzZmeWZnIiwiZW1haWwiOiJhZG1pbiIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJmZWRlcmF0Z
                     WRfY2xhaW1zIjp7ImNvbm5lY3Rvcl9pZCI6ImxvY2FsIiwidXNlcl9pZCI6ImFkbWluIiwidXNlcl9uYW1lIjoiYWRtaW4ifX0.Bn9A_btzIWUw5IdYdEcSku5uEUfoTSBgyogYnjgAly99qEDVqK_3IWtMOThfHJSzMmcy17RYpR8ebW3cuk3OLgQ
                     KHfLLWzoZaLGSUWjG8bszAIbIDOBT7qMGbesEx01yKCOsFXUuhaqudt9f3iKrjjz3rCE9TOkhSKmCUH5NKgzzgW9iEPhrwWlMNtdmpWiF2nPp1G9DDzxfIOMMy6Pjf95-NzG5LSUQMY0inLAA_E2xAWozmRJRl78pRk7JvfU5WcEu9hboWwMbeXqUk
                     bgQq_puI6C_baQosWwzHtham32yz145h0r83LKLDkFXVhudfToAiwk4JrHUnxv-kmQ6rHaw"
        Version    : 0

        Comment    :
        CommentUri :
        HttpOnly   : True
        Discard    : False
        Domain     : myConcourseUrl.com
        Expired    : False
        Expires    : 03.09.2020 10:53:19
        Name       : skymarshal_csrf
        Path       : /
        Port       :
        Secure     : False
        TimeStamp  : 02.09.2020 10:53:20
        Value      : 8bc676b0d727bc01efd8f664cc8b4844700b556f6a54b9605b90b98f92bb8977
        Version    : 0

        .LINK

        https://azd.tool.zfu.zb/DevOpsCollection/PowershellModules/_git/concourse?path=%2Fconcourse.psm1&version=GBmaster&line=4&lineStyle=plain&lineEnd=4&lineStartColumn=10&lineEndColumn=30

    #>


}
function Get-ConcoursePipeline {
    param (
        # Name of the pipeline
        [string]
        [AllowEmptyString()]
        $pipeline,
        # Name of the team
        [string]
        [AllowEmptyString()]
        $team,
        # Cookie
        [ValidateNotNullOrEmpty()]
        $ciCookie,
        # Auth
        [ValidateNotNullOrEmpty()]
        $concourseUrl
    )
    $cookieObject = New-Object System.Net.Cookie
    $ciCookies = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $ciCookie | ForEach-Object {
        $cookieObject.Domain = $_.Domain
        $cookieObject.Name = $_.Name
        $cookieObject.HttpOnly = $_.HttpOnly
        $cookieObject.Discard = $_.Discard
        $cookieObject.Expired = $_.Expired
        $cookieObject.Expires = $_.Expires
        $cookieObject.Path = $_.Path
        $cookieObject.Value = $_.Value
        $cookieObject.Secure = $_.Secure
        $cookieObject.Version = $_.Version
        $ciCookies.Cookies.Add($cookieObject)
    }
    $pipelines = $null
    try {
        $pipelines = Invoke-RestMethod -Uri "$concourseUrl/api/v1/pipelines" -Method Get -WebSession $ciCookies -SkipCertificateCheck
        if(-not [string]::IsNullOrEmpty($pipeline)) {
            $pipelines = $pipelines | Where-Object {$_.name -eq $pipeline}
        }
        if(-not [string]::IsNullOrEmpty($team)) {
            $pipelines = $pipelines | Where-Object {$_.team_name -eq $team}
        }
        return $pipelines
    }
    catch {
        $exception = $PSItem | Select-Object * | Format-Custom -Depth 1 | Out-String
        Throw $exception
    }
    <#
        .SYNOPSIS
        Fetches pipelines that fit parameters.

        .DESCRIPTION
        Fetches pipelines that fit parameters. Parameters can be pipeline name or a team. If no parameters specified, returns all pipelines that user has access.

        .PARAMETER pipeline
        Name of the pipeline.

        .PARAMETER team
        Name of the team.

        .PARAMETER concourseUrl
        Specifies the base url of Concourse.

        .PARAMETER ciCookie
        ciCookie is used to authenticate Concourse APIs.


        .INPUTS
        None.

        .OUTPUTS
        System.Collections.ArrayList. Get-ConcoursePipeline fetches pipelines that fit parameters.


        .EXAMPLE
        PS> $auth = Invoke-ConcourseAuth -user "myUser" -pass "myPass" -concourseUrl "http://myConcourseUrl.com" -loginType "local"
        PS> Get-ConcoursePipeline -pipeline "myPipeline" -concourseUrl "http://myConcourseUrl.com" -ciCookie $auth

        id           : 380
        name         : myPipeline
        paused       : False
        public       : False
        archived     : False
        team_name    : myTeam
        last_updated : 1598513097



        .EXAMPLE
        PS> Get-ConcoursePipeline -team "main" -concourseUrl "http://myConcourseUrl.com" -ciCookie $auth
        name         : concourse-pin-resource
        paused       : False
        public       : False
        archived     : False
        team_name    : main
        last_updated : 1590748896

        id           : 2447
        name         : restart-omnichannel-api-prod
        paused       : False
        public       : False
        archived     : False
        team_name    : main
        last_updated : 1592465707

        .LINK



    #>

}
function Build-ConcourseJob {
    [OutputType([System.Collections.Hashtable])]
    param (
        # Name of the pipeline
        [string]
        [ValidateNotNullOrEmpty()]
        $pipeline,
        # Name of the team
        [string]
        [ValidateNotNullOrEmpty()]
        $team,
        # Name of the team
        [string]
        [ValidateNotNullOrEmpty()]
        $job,
        # Cookie
        [ValidateNotNullOrEmpty()]
        $ciCookie,
        # Auth
        [ValidateNotNullOrEmpty()]
        $concourseUrl
    )
    $cookieObject = New-Object System.Net.Cookie
    $ciCookies = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $build = $null

    try {
        $ciCookie | ForEach-Object {
            Write-Verbose -Message "Adding cookie $($_.Name) : $($_.Value)"
            $cookieObject.Domain = $_.Domain
            $cookieObject.Name = $_.Name
            $cookieObject.HttpOnly = $_.HttpOnly
            $cookieObject.Discard = $_.Discard
            $cookieObject.Expired = $_.Expired
            $cookieObject.Expires = $_.Expires
            $cookieObject.Path = $_.Path
            $cookieObject.Value = $_.Value
            $cookieObject.Secure = $_.Secure
            $cookieObject.Version = $_.Version
            $ciCookies.Cookies.Add($cookieObject)
        }

        $request = @{
            Headers = @{
                "X-Csrf-Token" = ($ciCookie | Where-Object{$_.Name -eq "skymarshal_csrf"}).Value
            }
            Uri = "$concourseUrl/api/v1/teams/$team/pipelines/$pipeline/jobs/$job/builds"
            Method = "Post"
            WebSession = $ciCookies
            SkipCertificateCheck = $true
        }
        Write-Verbose -Message "Created request parameters: $($request | ConvertTo-Json)"
        $build = Invoke-RestMethod  @request
        Write-Verbose -Message "Build triggered: $($build | out-string)"
        return $build
    }
    catch {
        $exception = $PSItem | Select-Object * | Format-Custom -Depth 1 | Out-String
        Write-Error $exception
    }
    <#
        .SYNOPSIS
        Triggers a new Concourse job build.

        .DESCRIPTION
        Using given team, pipeline and job parameters, triggers a new build.

        .PARAMETER pipeline
        Name of the pipeline.

        .PARAMETER team
        Name of the team.

        .PARAMETER job
        Name of the job.

        .PARAMETER concourseUrl
        Specifies the base url of Concourse.

        .PARAMETER ciCookie
        ciCookie is used to authenticate Concourse APIs.


        .INPUTS
        None.

        .OUTPUTS
        System.Collections.Hashtable. Build-ConcourseJob returns the details of newly triggered job.


        .EXAMPLE
        PS> $auth = Invoke-ConcourseAuth -user "myUser" -pass "myPass" -concourseUrl "http://myConcourseUrl.com" -loginType "local"
        PS> Build-ConcourseJob -team "myTeam" -pipeline "myPipeline" -job "set-params-uat" -concourseUrl "http://myConcourseUrl.com" -ciCookie $auth

        id            : 1366609
        team_name     : myTeam
        name          : 36
        status        : pending
        job_name      : set-params-uat
        api_url       : /api/v1/builds/1366609
        pipeline_name : myPipeline

        .LINK
    #>

}
function Get-ConcourseJob {
    [OutputType([System.Collections.Hashtable])]
    param (
        # ID of the build
        [string]
        [AllowEmptyString()]
        $buildID,
        # Name of the job
        [string]
        [ValidateNotNullOrEmpty()]
        $job,
        # Name of the pipeline
        [string]
        [ValidateNotNullOrEmpty()]
        $pipeline,
        # Name of the team
        [string]
        [ValidateNotNullOrEmpty()]
        $team,
        # Cookie
        [ValidateNotNullOrEmpty()]
        $ciCookie,
        # Auth
        [ValidateNotNullOrEmpty()]
        $concourseUrl
    )
    $cookieObject = New-Object System.Net.Cookie
    $ciCookies = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $jobStatus = $null
    try {
        $ciCookie | ForEach-Object {
            $cookieObject.Domain = $_.Domain
            $cookieObject.Name = $_.Name
            $cookieObject.HttpOnly = $_.HttpOnly
            $cookieObject.Discard = $_.Discard
            $cookieObject.Expired = $_.Expired
            $cookieObject.Expires = $_.Expires
            $cookieObject.Path = $_.Path
            $cookieObject.Value = $_.Value
            $cookieObject.Secure = $_.Secure
            $cookieObject.Version = $_.Version
            $ciCookies.Cookies.Add($cookieObject)
        }
        $url = [string]::IsNullOrEmpty($buildID) ? "$concourseUrl/api/v1/teams/$team/pipelines/$pipeline/jobs/$job" : "$concourseUrl/api/v1/teams/$team/pipelines/$pipeline/jobs/$job/builds/$buildID"
        $request = @{
            Uri = $url
            Method = "Get"
            WebSession = $ciCookies
            SkipCertificateCheck = $true
        }
        Write-Verbose -Message "Created request parameters: $($request | ConvertTo-Json)"
        $jobStatus = Invoke-RestMethod @request
        return $jobStatus
        }
        catch {
            $exception = $PSItem | Select-Object * | Format-Custom -Depth 1 | Out-String
            Throw $exception
        }
    <#
        .SYNOPSIS
        Gets the status of given Concourse job.

        .DESCRIPTION
        Using given team, pipeline and job parameters, gets the status of Concourse job. If buildID is not specified, returns all existing job status.

        .PARAMETER pipeline
        Name of the pipeline.

        .PARAMETER team
        Name of the team.

        .PARAMETER job
        Name of the job.

        .PARAMETER buildID
        Build number of the job.

        .PARAMETER concourseUrl
        Specifies the base url of Concourse.

        .PARAMETER ciCookie
        ciCookie is used to authenticate Concourse APIs.

        .INPUTS
        None.

        .OUTPUTS
        System.Collections.Hashtable.  Get-ConcourseJob returns the details of given job and build number.


        .EXAMPLE
        PS> $auth = Invoke-ConcourseAuth -user "myUser" -pass "myPass" -concourseUrl "http://myConcourseUrl.com" -loginType "local"
        PS> Get-ConcourseJob -job "set-params-uat" -pipeline "myPipeline" -team "myTeam" -ciCookie $auth -concourseUrl "http://myConcourseUrl.com"

        id                    : 7922
        name                  : set-params-uat
        pipeline_name         : myPipeline
        team_name             : myTeam
        first_logged_build_id : 1364252
        next_build            : @{id=1366571; team_name=myTeam; name=34; status=started; job_name=set-params-uat; api_url=/api/v1/builds/1366571; pipeline_name=myPipeline; start_time=1599045473}
        finished_build        : @{id=1366558; team_name=myTeam; name=33; status=failed; job_name=set-params-uat; api_url=/api/v1/builds/1366558; pipeline_name=myPipeline; start_time=1599045093; end_time=1599045420}
        inputs                : {@{name=cf-powershell; resource=cf-powershell; trigger=False}, @{name=myPipelineurations-uat; resource=myPipelineurations-uat; trigger=True}}
        groups                :

        .EXAMPLE
        PS> Get-ConcourseJob -job "set-params-uat" -pipeline "myPipeline" -team "myTeam" -ciCookie $auth -concourseUrl "http://myConcourseUrl.com" -buildID 34

        id            : 1366571
        team_name     : myTeam
        name          : 34
        status        : started
        job_name      : set-params-uat
        api_url       : /api/v1/builds/1366571
        pipeline_name : myPipeline
        start_time    : 1599045473

        .LINK
    #>

}

function Get-ConcourseModuleParams {
    [CmdletBinding()]
    param (
    )
    begin {
    }
    process {
        Get-Variable -Scope Script
    }
    end {
    }
}
function Set-FlyPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
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
        [Parameter(Mandatory = $true,
            HelpMessage = "Download Path for Fly")]
        [ValidateNotNullOrEmpty()]
        [string]
        $path,
        [Parameter(Mandatory = $true,
            HelpMessage = "URL of FLY Executable")]
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
            if ($IsLinux) {
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
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [String]
        $concourseUrl,
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]$cred,
        [String]
        $team = "main",
        [String]
        $alias = "devops"
    )
    begin {
        $Script:alias = $alias
        Write-Verbose -Message "Setting fly path $Script:flyPath"
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
        $userName = $cred.UserName
        $password = $cred.GetNetworkCredential().password
    }
    process {
        try {
            $login = Invoke-Fly -t $Script:alias login -c $concourseUrl -k -u $username -p $password -n $team 2>&1
            if (($login | out-string) -match "target saved") {
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
function Invoke-ConcourseJob {
    [CmdletBinding()]
    param (
        # Pipeline name
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $pipeline,
        # Pipeline's job name
        [Parameter(Mandatory = $true)]
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
            return Invoke-Fly -t $Script:alias trigger-job -j $pipeline/$job -w 2>&1
        }
        else {
            $result = Invoke-Fly -t $Script:alias trigger-job -j $pipeline/$job 2>&1
            if ($?) {
                return @{
                    State    = $result.Split(" ")[0]
                    Job      = $job
                    Pipeline = $pipeline
                    Id       = $result.Split(" ")[2]
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
function Test-ConcourseLoginStatus {
    [CmdletBinding()]
    param (    )
    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
    }
    process {
        $result = Invoke-Fly -t $Script:alias status 2>&1
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
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $pipeline,
        # Pipeline's job name
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $job,
        # Job's build id
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]
        $build
    )
    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
    }
    process {
        $result = Invoke-Fly -t $Script:alias watch -j $pipeline/$job -b $build -t 2>&1
        Write-Verbose -Message "Received: $result"
        if (-not $? -or ($result | Out-String) -match "^(error:) *") {
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
        [Parameter(Mandatory = $false)]
        $query,
        # Parameter help description
        [Parameter(Mandatory = $false)]
        [int]
        $since = 30,
        # Parameter help description
        [Parameter(Mandatory = $false)]
        [int]
        $count = 1000
    )
    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
        $date = (Get-Date).AddMinutes(-$since).ToString("yyyy-MM-dd HH:mm:ss")
        $builds = Invoke-Fly -t $Script:alias builds --since $date -c $count --json 2>&1
        if (-not $?) {
            $errorMessage = "$($builds | out-string)`n$(($_ | Select-Object -ExpandProperty invocationinfo).PositionMessage)"
            throw $errorMessage
        }
    }
    process {
        Write-Verbose "hash: $($query | ConvertTo-Json)"
        $builds = $builds | ConvertFrom-Json
        foreach ($key in $query.Keys) {
            Write-Verbose "filtering for key : $key and value : $query['$key']"
            $builds = $builds | Where-Object { $_."$key" -eq $query["$key"] }
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
        $workers = Invoke-Fly -t $Script:alias workers --json 2>&1
        if (-not $?) {
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
function Get-PrunedWorkers {
    [CmdletBinding()]
    param ()
    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
        $workers = Get-ConcourseWorkers
    }
    process {
        $workers = $workers | ConvertFrom-Json
        $stalledWorkers = $workers | Where-Object { $_.state -eq "stalled" }
        $result = "No stalled workers found to prune."
        if ($stalledWorkers.count -gt 0) {
            Invoke-Fly -t $Script:alias prune-worker --all-stalled
            $result = "Deleted  $($stalledWorkers.name) Workers"
        }
        return $result
    }
    end {
    }
}
function Set-ConcourseTeamAuth {
    [CmdletBinding()]
    param (
        # Teamname
        [Parameter(mandatory = $True)]
        [string]
        $team,
        # Team auth filepath
        [Parameter(Mandatory = $True)]
        [string]
        $filepath
    )
    begin {
       Set-Alias -Name Invoke-Fly -Value $Script:flyPath
    }
    process {
        try {
            if (-not (test-path -Path $filepath)) {
                Throw "Unable to find yml: $filepath"
            }
            Invoke-Fly -t $Script:alias set-team -n $team -c $filepath --non-interactive
        }
        catch {
            $exception = $PSItem | Select-Object * | Format-Custom -Depth 1 | Out-String
            Write-Error -Message $exception -ErrorAction Stop
        }
    }
    end {
    }
}

function Get-ConcourseJobStatus {
    [CmdletBinding()]
    param (
        # Pipeline name
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $pipeline,
        # Pipeline's job name
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $job,
        # Job's build id
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]
        $build,
        [int]
        $last = 100

    )

    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
    }

    process {
        $jobStatus = Invoke-Fly -t $Script:alias builds -a -c $last -j $pipeline/$job --json 2>&1
        if ($?) {
            return $($jobStatus | ConvertFrom-Json) | Where-Object { $_.name -eq $build }
        }
        else {
            $errorMessage = "$($jobStatus | out-string)`n$(($_ | Select-Object -ExpandProperty invocationinfo).PositionMessage)"
            throw "Catched an exception in Function:$($MyInvocation.MyCommand)`n$errorMessage"
        }
    }

    end {
    }
}

function Get-ConcoursePipelines {
    [CmdletBinding()]
    param (
        # Name of the pipeline
        [Parameter(Mandatory=$false)]
        [string]
        [ValidateNotNullOrEmpty()]
        $pipelineName,
        # Name of the team
        [Parameter(Mandatory=$false)]
        [string]
        [ValidateNotNullOrEmpty()]
        $team
    )

    begin {
        Set-Alias -Name Invoke-Fly -Value $Script:flyPath
    }

    process {
        $pipelines = $null
        try {
            $pipelines = Invoke-Fly -t $Script:alias curl -- /api/v1/pipelines | ConvertFrom-Json
            if(-not [string]::IsNullOrEmpty($pipelineName)) {
                $pipelines = $pipelines | Where-Object {$_.name -eq $pipelineName}
            }
            if(-not [string]::IsNullOrEmpty($team)) {
                $pipelines = $pipelines | Where-Object {$_.team_name -eq $team}
            }
        }
        catch {
            $exception = $PSItem | Select-Object * | Format-Custom -Depth 1 | Out-String
            Write-Error -Message $exception -ErrorAction Stop
        }

        return $($pipelines | ConvertTo-Json -Compress)
    }

    end {

    }
}


# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*