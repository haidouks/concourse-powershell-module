$concourseUrl = "http://******"
$concourseBaseUri = ([System.Uri]$concourseUrl).Host
$userName = "***"
$pass = "***"
$ldapUserName = "***"
$ldapUserPass = "***"
$password = ConvertTo-SecureString -String $pass -AsPlainText -Force
$testPipeline = "***"
$testJob = "***"
$testbuildID = "***"
$testTeam = "***"
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$invalidCred = new-object -typename System.Management.Automation.PSCredential -argumentlist "$username-shoulfail", $password
$global:auth = $null

$flyPath = Join-Path -Path $PSScriptRoot -ChildPath fly
$platform = "linux"
if ($IsWindows) {
    $platform = "windows"
    $flyPath += ".exe"
}

$ModuleManifestName = 'concourse.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

Import-Module $ModuleManifestPath -Force

Describe "Invoke-ConcourseAuth" {
    Context "If Auth type is local and credentials are valid" {
        It "It should return skymarshal_auth0" {
            $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType local
            ($auth | Where-Object{$_.Name -eq "skymarshal_auth0"}).Value -match "bearer *" | Should -Be $true -Because "Local user $userName successfully logged in"
        }
    }
    Context "If Auth type is ldap and credentials are valid" {
        It "It should return skymarshal_auth0" {
            $authLdap = Invoke-ConcourseAuth -user "$ldapUserName" -pass "$ldapUserPass" -concourseUrl $concourseUrl -loginType ldap
            ($authLdap | Where-Object{$_.Name -eq "skymarshal_auth0"}).Value -match "bearer *" | Should -Be $true -Because "Ldap user $userName successfully logged in"
        }
    }

    Context "If Auth type is ldap and credentials are invalid" {
        It "It should return skymarshal_auth0" {
            {Invoke-ConcourseAuth -user "$ldapUserName" -pass "__$ldapUserPass" -concourseUrl $concourseUrl -loginType ldap} | Should -Throw
        }
    }
}

Describe "Invoke-ConcourseAuth" {
    Context "If Auth type is local and credentials are valid" {
        It "It should trigger new Concourse build" {
            $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType local
            $job = Build-ConcourseJob -pipeline $testPipeline -ciCookie $auth -team $testTeam -job $testJob -concourseUrl $concourseUrl
            $job.id | Should -Not -BeNullOrEmpty

        }
    }
}

Describe 'Get-FlyCLI' {
    Context 'If Parameters are missing or not valid, It should fail' {
        It 'Parameters are not valid' {
            { Get-FlyCLI -url "http://$concourseBaseUri/api/v1/cli?arch=amd64&platform=$platform" -path "" } | Should -Throw
        }
        It 'Url is not valid' {
            { Get-FlyCLI -url "http://____$concourseBaseUri/api/v1/cli?arch=amd64&platform=$platform" -path $flyPath } | Should -Throw
        }
    }

    Context 'Download Fly CLI Successfully' {
        It 'If Url and Destination path is correct, there should be no exception' {

            { Get-FlyCLI -path $flyPath -url "http://$concourseBaseUri/api/v1/cli?arch=amd64&platform=$platform" } | Should -Not -Throw
        }
        It 'Fly CLI should be there' {
            Test-Path -Path $flyPath | Should -Be $true
        }
        It 'Its size should be more than 1 mb' {
            ((Get-Item -Path $flyPath).Length / 1mb) -ge 1 | Should -Be $true
        }
    }
}

if ($IsLinux) {
    chmod 777 $flyPath
}

Describe 'Register-Concourse' {
    Context 'Login Operations' {
        It 'If I login with wrong credentials' {
            { Register-Concourse -concourseUrl $concourseUrl -cred $invalidCred } | should -Throw
        }
        It 'If I login with correct credentials to a different team' {
            { Register-Concourse -concourseUrl $concourseUrl -cred $cred -team "zt"} | should -Not -Throw
        }
        It 'If I login with correct credentials' {
            { Register-Concourse -concourseUrl $concourseUrl -cred $cred -team $testTeam } | should -Not -Throw
        }
        It 'If I login with correct credentials' {
            { Register-Concourse -concourseUrl $concourseUrl -cred $cred -team $testTeam } | should -Not -Throw
        }
        It 'If I login with correct credentials to a different alias' {
            { Register-Concourse -concourseUrl $concourseUrl -cred $cred -team $testTeam -alias "ZT-Devops" } | should -Not -Throw
            ((Get-ConcourseModuleParams) | Where-Object{$_.Name -eq "alias"}).Value | should -Be "ZT-Devops"
        }
    }

}

Describe "Get-ConcourseJob" {
    Context "Get job object from concourse" {
        $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType local
        It "If build id is valid" {
            (Get-ConcourseJob -pipeline $testPipeline -job $testJob -buildID $testbuildID -ciCookie $auth -concourseUrl $concourseUrl -team $testTeam).name | Should -Be $testbuildID
        }
        It "If build id is not specified, latest build info should return" {
            (Get-ConcourseJob -pipeline $testPipeline -job $testJob -ciCookie $auth -concourseUrl $concourseUrl -team $testTeam).pipeline_name | Should -Be $testPipeline
        }
    }
}

Describe "Test-ConcourseLoginStatus" {
    Context "Check Login status" {
        It "If logged in" {
            Test-ConcourseLoginStatus | Should -Be $true
        }
    }
}


Describe "Get-ConcourseJobLog" {
    Context "If parameters are valid" {
        It "It should return the output of job" {
            (Get-ConcourseJobLog -pipeline $testPipeline -job $testJob -build $testbuildID)[0] | Should -Match "Identity added"
        }
        It "It should not return exception" {
            { Get-ConcourseJobLog -pipeline $testPipeline -job $testJob -build $testbuildID } | Should -Not -Throw
        }
    }
    Context "If parameters are invalid" {

        It "It should return exception unknown pipeline" {
            { Get-ConcourseJobLog -pipeline "___$testPipeline" -job $testJob -build $testbuildID} | Should  -Throw
        }
    }
}

Describe "Get-ConcourseJobStatus" {
    Context "Get job object from concourse" {
        It "If build id is valid" {
            (Get-ConcourseJobStatus -pipeline $testPipeline -job $testJob -build $testBuild).name | Should -Be $testBuild
        }
    }
}

Describe "Get-ConcoursePipelines" {
    Context "If parameters are valid" {
        It "It should return all pipeline if no pipeline name specified" {
            (Get-ConcoursePipelines | ConvertFrom-Json).Count | Should -BeGreaterThan 1000
        }
        It "It should return the pipeline if pipeline name specified" {
            (Get-ConcoursePipelines -pipelineName $testPipeline) | ConvertFrom-Json | Should -HaveType ([PSCustomObject])
        }
        It "It should return the pipeline if pipeline name specified" {
            (Get-ConcoursePipelines -pipelineName $testPipeline) | ConvertFrom-Json | Should -HaveType ([PSCustomObject])
        }
        It "It should return the all information about pipeline if pipeline name specified" {
            ((Get-ConcoursePipelines -pipelineName "fed-cdn-app") | ConvertFrom-Json).team_name | Should -Contain "fed-vip"
        }
        It "It should return the all pipelines if only team specified" {
            ((Get-ConcoursePipelines -team $testTeam) | ConvertFrom-Json).count | Should -BeGreaterThan 50
        }
    }
}




Describe "Get-ConcoursePipeline" {
    Context "If parameters are valid" {
        $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType local
        It "It should return all pipeline if no pipeline name specified" {
            $pipelines = Get-ConcoursePipeline -ciCookie $auth -concourseUrl $concourseUrl
            $pipelines.Count | Should -BeGreaterOrEqual 1000
        }
        It "It should return the pipeline if pipeline name specified" {
            Get-ConcoursePipeline -ciCookie $auth -concourseUrl $concourseUrl  -pipeline $testPipeline  | Should -BeOfType [PSCustomObject]
        }
        It "It should return the all information about pipeline if pipeline name specified" {
            ((Get-ConcoursePipeline -ciCookie $auth -concourseUrl $concourseUrl  -pipeline $testPipeline) ).team_name | Should -Contain $testTeam
        }
        It "It should return the all pipelines if only team specified" {
            ((Get-ConcoursePipeline -ciCookie $auth -concourseUrl $concourseUrl  -team $testTeam)).count | Should -BeGreaterThan 50
        }
    }
}

Describe "Get-ConcourseBuilds" {
    Context "If since parameters exist" {
        It "It should return builds given since time parameter" {
            (Get-ConcourseBuilds -since 300).Length | Should -BeGreaterThan 1
        }
        It "It should return the builds if builds is succeeded" {
            Get-ConcourseBuilds -query @{status = "succeeded" } | ConvertFrom-Json | Should -HaveType [PSCustomObject]
        }
        It "If you limit the result It should return desired count of builds " {
            (Get-ConcourseBuilds -count 3 | ConvertFrom-Json).count | Should -be 3
        }
    }
}

Describe "Get-ConcourseWorkers" {
    Context "If running worker exist" {
        It "It should return running worker more than 1" {
            ((Get-ConcourseWorkers | ConvertFrom-Json) | Where-Object { $_.state -eq "running" }).count | Should -BeGreaterThan 1
        }
    }
}


Describe "Get-PrunedWorkers" {
    Context "Check prune workers " {
        It "It should return function result" {
            (Get-PrunedWorkers).count | Should -BeGreaterThan 0
        }
    }
}

Describe "Clear workspace" {
    Context "Remove fly" {
        It "If fly path is valid, it should remove fly successfully" {
            {Remove-Item -Path $flyPath -Force} | Should -Not -Throw
            Test-Path -Path $flyPath | Should -Be $false
        }
    }
}