$VerbosePreference = "Continue"
$ModuleManifestName = 'concourse.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"
Write-Verbose -Message "Module path: $ModuleManifestPath"
Import-Module $ModuleManifestPath -Force -Verbose

BeforeAll {
    $ModuleManifestName = 'concourse.psd1'
    $ModuleManifestPath = "$PSScriptRoot/../$ModuleManifestName"
    Write-Verbose -Message "PSScriptRoot: $PSScriptRoot"
    $userName = "test"
    $pass = "test"
    $pipeline = "test"
    $job = "test-job"
    $team = "main"
    $concourseUrl = "http://localhost:8080"
    $buildID = 1

}

Describe "Set First Pipeline" {
    Context "If cli path is valid" {
        It "Should download fly cli" {
            if ($IsMacOS) {
                $cliUrl = "$concourseUrl/api/v1/cli?arch=amd64&platform=darwin"
                Invoke-RestMethod -Uri $cliUrl -OutFile ./fly
                chmod +x fly
            }
            elseif ($IsLinux) {
                $cliUrl = "$concourseUrl/api/v1/cli?arch=amd64&platform=linux"
                Invoke-RestMethod -Uri $cliUrl -OutFile ./fly
                chmod +x fly
            }
            elseif ($IsWindows) {
                $cliUrl = "$concourseUrl/api/v1/cli?arch=amd64&platform=windows"
                Invoke-RestMethod -Uri $cliUrl -OutFile ./fly
            }
            Test-Path ./fly | Should -Be $true
        }
    }
    Context "Login to Concourse" {
        It "If credentials are valid, fly should login to concourse" {
            ./fly -t $team  login -c $concourseUrl -u $userName  -p $pass
            (./fly -t main teams --json | convertfrom-json).name | Should -Contain $team
            $pipelineYml = "$PSScriptRoot/sample-pipeline.yml"
            Write-Verbose -Message "Creating pipeline($pipeline) from yml $pipelineYml" -Verbose
            ./fly -t $team  sp -n -p $pipeline -c $pipelineYml
            (./fly -t main pipelines --json | convertfrom-json).name | Should -Contain $pipeline
        }
        It "Should delete fly" {
            Remove-Item -Path ./fly -Force
            Test-Path -Path ./fly | Should -Be $false
        }
    }
}



Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
        $? | Should -Be $true
    }
}

Describe "Invoke-ConcourseAuth" {

    Context "If Auth type is local and credentials are valid" {
        It "It should return skymarshal_auth" {
            $VerbosePreference = "Continue"
            $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType local
            ($auth | Where-Object { $_.Name -eq "skymarshal_auth" }).Value -match "bearer *" | Should -Be $true -Because "Local user $userName successfully logged in"
        }
    }

    Context "If Auth type is local and credentials are invalid" {
        It "It should return skymarshal_auth" {
            { Invoke-ConcourseAuth -user "$userName" -pass "__$pass" -concourseUrl $concourseUrl -loginType local } | Should -Throw
        }
    }
}

Describe "Build-ConcourseJob" {
    Context "If Auth type is local and credentials are valid" {
        It "It should trigger new Concourse build" {
            $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType local
            $job = Invoke-ConcourseJob -pipeline $pipeline -ciCookie $auth -team $team -job $job -concourseUrl $concourseUrl
            $job.id | Should -Not -BeNullOrEmpty

        }
    }
}


Describe "Get-ConcourseJobStatus" {
    BeforeAll {
        $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType local
    }
    Context "Get job object from concourse" {

        It "If build id is valid" {
            (Get-ConcourseJobStatus -pipeline $pipeline -job $job -buildID $buildID -ciCookie $auth -concourseUrl $concourseUrl -team $team).name | Should -Be $buildID
        }
        It "If build id is not specified, latest build info should return" {
            (Get-ConcourseJobStatus -pipeline $pipeline -job $job -ciCookie $auth -concourseUrl $concourseUrl -team $team).pipeline_name | Should -Be $pipeline
        }
    }
}


Describe "Get-ConcoursePipeline" {
    BeforeAll {
        $auth = Invoke-ConcourseAuth -user $userName -pass $pass -concourseUrl $concourseUrl -loginType local
    }
    Context "If parameters are valid" {
        It "It should return all pipeline if no pipeline name specified" {
            $pipelines = Get-ConcoursePipeline -ciCookie $auth -concourseUrl $concourseUrl
            $pipelines.Count | Should -BeGreaterOrEqual 1
        }
        It "It should return the pipeline if pipeline name specified" {
            Get-ConcoursePipeline -ciCookie $auth -concourseUrl $concourseUrl  -pipeline $pipeline  | Should -BeOfType [PSCustomObject]
        }
        It "It should return the all information about pipeline if pipeline name specified" {
            ((Get-ConcoursePipeline -ciCookie $auth -concourseUrl $concourseUrl  -pipeline $pipeline) ).team_name | Should -Contain $team
        }
        It "It should return the all pipelines if only team specified" {
            ((Get-ConcoursePipeline -ciCookie $auth -concourseUrl $concourseUrl  -team $team)).count | Should -BeGreaterOrEqual 1
        }
    }
}

