Install-Module -Name Pode -Force
Import-Module -Name Pode
Start-PodeServer -Threads 2 {
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging
    New-PodeLoggingMethod -Terminal | Enable-PodeRequestLogging
    Add-PodeEndpoint -Address * -Port 80 -Protocol Http
    ConvertTo-PodeRoute -Module concourse
    Enable-PodeOpenApi -Path '/docs/openapi' -Title 'Concourse' -Version 1.0.0.0

    Enable-PodeOpenApiViewer -Type Swagger -Path '/docs/swagger' -DarkMode
}