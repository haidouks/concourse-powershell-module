$concourseUrl = "http://localhost:8080"
$userName = "test"
$pass = "test"
$ldapUserName = "***"
$ldapUserPass = "***"
$testPipeline = "***"
$testJob = "***"
$testbuildID = "***"
$testTeam = "***"

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

Describe "Build-ConcourseJob" {
    Context "If Auth type is local and credentials are valid" {
        It "It should trigger new Concourse build" {
            $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType local
            $job = Build-ConcourseJob -pipeline $testPipeline -ciCookie $auth -team $testTeam -job $testJob -concourseUrl $concourseUrl
            $job.id | Should -Not -BeNullOrEmpty

        }
    }
}


Describe "Get-ConcourseJobStatus" {
    Context "Get job object from concourse" {
        $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType local
        It "If build id is valid" {
            (Get-ConcourseJobStatus -pipeline $testPipeline -job $testJob -buildID $testbuildID -ciCookie $auth -concourseUrl $concourseUrl -team $testTeam).name | Should -Be $testbuildID
        }
        It "If build id is not specified, latest build info should return" {
            (Get-ConcourseJobStatus -pipeline $testPipeline -job $testJob -ciCookie $auth -concourseUrl $concourseUrl -team $testTeam).pipeline_name | Should -Be $testPipeline
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
