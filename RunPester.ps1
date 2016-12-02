[CmdletBinding()]
<#
.SYNOPSIS
Ce script lance des tests Pester avec Jenkins
 
.DESCRIPTION

.PARAMETER IISSite
Nom du site web � tester avec Pester

.PARAMETER IISPool
Nom du pool d'application qui contient le site web pour le tester avec Pester

.PARAMETER OutFile
Correspond au nom du fichier du rapport XML qui va �tre g�n�r�.


#>

 param (
    [Parameter(Mandatory=$true)]
    [String]$OutFile,
    [String]$IISSite,
    [String]$IISPool

 )

 Try {
 	    Invoke-Pester -verbose -OutputFile $OutFile -OutputFormat NUnitXml `
                      -EnableExit -Script @{ Path = "Tests"; Parameters = @{IISSite = $IISSite;
                                                             IISPool = $IISPool};}
 }
 Catch {
    Write-Output "Test"
    Exit 1
 }