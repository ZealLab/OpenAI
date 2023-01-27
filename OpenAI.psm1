Function New-AIImage {
<#
 .SYNOPSIS
   Used to Create AI Generated Images

 .DESCRIPTION
   Generates AI images utilizing the OpenAI framework API

 .EXAMPLE
   New-AIImage -APIKey XXXXXXXXXXXXXXXXXXXXXXX -Query "Cat playing with ball"

 .EXAMPLE
   New-AIImage -APIKey XXXXXXXXXXXXXXXXXXXXXXX -Query "Cat playing with ball" -OutPath "C:\Temp" -Quantity 10

 .PARAMETER Query
   The quwry used to generate the AI Image(s)

 .PARAMETER Quantity
   The amount of images you want to generate (Max 10)

 .PARAMETER OutPath
   The directory path to generate the images

 .PARAMETER APIKey
   Your OpenAI API Key that can be obtained from https://beta.openai.com/

 .NOTES
   Author: Ryan Bowen
   Date:   December 29, 2022
#>
    [CmdletBinding()]
    Param (
    [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
    [String]$Query,
    [Parameter(Mandatory=$false, ValueFromPipeline = $true)]
    [Int]$Quantity,
    [Parameter(Mandatory=$false, ValueFromPipeline = $true)]
    [String]$OutPath,
    [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
    [String]$APIKey
    )
    if (!$Quantity)
    {
        $Quantity = 1
    }
    if (!$OutPath)
    {
        $OutPath = $env:USERPROFILE
    }
    $url = "https://api.openai.com/v1/images/generations"
    $content = "application/json"
    $header = @{Authorization = "Bearer $APIKey"}
    $body = @{
        'prompt' = $Query
        'n' = $Quantity
        "size" = "1024x1024"
        } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri $url -Headers $header -Body $body -Method Post -ContentType $content
    if (!(Test-Path "$OutPath\$Query" -ErrorAction SilentlyContinue))
    {
        New-Item -ItemType Directory -Name $Query -Path $OutPath
    }
    ForEach ($image in $result.data.url)
    {
        Invoke-WebRequest -Uri $image -OutFile "$OutPath\$Query\$Quantity.png"
        Write-Host -ForegroundColor Green "$OutPath\$Query\$Quantity.png"
        $Quantity = $Quantity - 1
    }
}
Export-ModuleMember -Function "New-AIImage"
