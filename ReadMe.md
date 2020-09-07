# Concourse Module for Powershell

## Installation

```` Powershell
Install-Module -Name Concourse
````

## Usage

Easy way to discover all commands is using ``Get-Command``. This command will list all available functions within Concourse module.
```` Powershell
Get-Command -Module Concourse
````
#
Helpers and descriptions are available for all of functions.

```` Powershell
Get-Help Invoke-ConcourseAuth -Full

````
#
### Example 1

Script below can be used to trigger a new build for job 'myJob'.
```` Powershell
PS: /> $user = "myUser"
PS: /> $pass = "myP@ss"
PS: /> $concourseUrl = "http://ci.concourse.com"
PS: /> $loginType = "local" #'ldap', 'github', etc ...
PS: /> $pipeline = "myPipeline"
PS: /> $job = "myJob"
PS: /> $team = "myTeam"
PS: /> $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType $loginType
PS: /> Invoke-ConcourseJob -pipeline $pipeline -ciCookie $auth -team $team -job $job -concourseUrl $concourseUrl

id            : 16
team_name     : myTeam
name          : 15
status        : pending
job_name      : myJob
api_url       : /api/v1/builds/16
pipeline_name : myPipeline
````

### Example 2

Script below can be used to get job status.
```` Powershell
PS: /> $user = "myUser"
PS: /> $pass = "myP@ss"
PS: /> $concourseUrl = "http://ci.concourse.com"
PS: /> $loginType = "local" #'ldap', 'github', etc ...
PS: /> $pipeline = "myPipeline"
PS: /> $job = "myJob"
PS: /> $team = "myTeam"
PS: /> $buildID = 1
PS: /> $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType $loginType
PS: /> Get-ConcourseJobStatus -pipeline $pipeline -job $job -buildID $buildID -ciCookie $auth -concourseUrl $concourseUrl -team $team

id            : 2
team_name     : myTeam
name          : 1
status        : succeeded
job_name      : myJob
api_url       : /api/v1/builds/2
pipeline_name : myPipeline
start_time    : 1599471001
end_time      : 1599471025
````

## Pipeline Status

| Build  |  Publish |
|---|---|
| [![Build Status](https://dev.azure.com/powershell-modules/Concourse/_apis/build/status/haidouks.concourse-powershell-module?branchName=master)](https://dev.azure.com/powershell-modules/Concourse/_build/latest?definitionId=3&branchName=master)  | [![Release Status](https://vsrm.dev.azure.com/powershell-modules/_apis/public/Release/badge/48e1e487-95a2-46c8-82ef-9d7709a68195/1/1)](https://vsrm.dev.azure.com/powershell-modules/_apis/public/Release/badge/48e1e487-95a2-46c8-82ef-9d7709a68195/1/1)|

