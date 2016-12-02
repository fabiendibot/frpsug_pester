[CmdletBinding()]
<#
.SYNOPSIS
Ce script lance des tests Pester avec Jenkins
 
.DESCRIPTION
Ce script par le biais d'une connexion WinRM va lancer l'import du module Pester pour faire des tests unitaires sur la configuration du IIS.
Une fois le module import�, il lance les tests qui sont dans sont r�pertoire courant, puis g�n�re un rapport au format XML NUnit que Jenkins 
est capable d'interpr�ter pour donner des informations fiables sur l'�tat du d�ploiement.
Ce rapport sera situ� dans le chemin correspondant � la variable $Source.

Pour lancer ce script dans Jenkins:
powerShell.exe -executionpolicy Bypass -File RunPester.ps1 -Source %WORKPLACE% -Target 'ibiigr09.srv-ib.dev' 
               -TestName 'ValidateCCV' -IISRoot 'D:\Inetpub\collecte-rmoe-ccv-poc' -Outfile 'ValidateCCV.XML' -DriveLetter 'P:'`               -LifePage 'http://collecte-rmoe-ccv-poc/Lifepage.aspx' -IISSite 'site-name' -IISPool 'Pool' -ApplicationVersion '1.0.1b' -ApplicationName 'CCV DEV'
 
.PARAMETER Source
Correspond � la variable %WORKPLACE% dans Jenkins.
 
.PARAMETER Target
C'est le serveur IIS sur lequel vous voulez jouer les tests.

.PARAMETER IISRoot
Correspond � la racine du site IIS � tester.

.PARAMETER LifePage
URL de la page de vie � tester

.PARAMETER IISSite
Nom du site web � tester avec Pester

.PARAMETER IISPool
Nom du pool d'application qui contient le site web pour le tester avec Pester

.PARAMETER TestName
Correspond au nom du jeu de tests � jouer.

.PARAMETER ApplicationVersion
Version de l'application qui doit �tre test� avec Pester

.PARAMETER ApplicationName
Nom de l'application qui doit �tre test� avec Pester

.PARAMETER OutFile
Correspond au nom du fichier du rapport XML qui va �tre g�n�r�.

.PARAMETER DriveLetter
Correspond � la lettre du lecteur r�seau temporaire qui va �tre cr�� pour copier le fichier XML de r�sultat.
 
.EXAMPLE
C:PS> RunPester.ps1 -Source %WORKPLACE% -Target 'ibiigr09.srv-ib.dev' -TestName 'ValidateCCV' -IISRoot 'D:\Inetpub\collecte-rmoe-ccv-poc' -Outfile 'ValidateCCV.XML' -DriveLetter 'P:' `
                    -LifePage 'http://collecte-rmoe-ccv-poc/Lifepage.aspx' -IISSite 'site-name' -IISPool 'Pool' -ApplicationVersion '1.0.1b' -ApplicationName 'CCV DEV'
 
#>

 param (
    [Parameter(Mandatory=$true)]
 	[String]$Source,
    [String]$Target,
    [String]$IISRoot,
    [String]$TestName,
    [String]$OutFile,
    [String]$DriveLetter,
    [String]$LifePage,
    [String]$IISSite,
    [String]$IISPool,
    [String]$ApplicationVersion,
    [String]$ApplicationName

 )

 Try {
     # V�rification si le lecteur $Driveletter n'est pas d�j� utilis� et qu'on ne copie pas le framework Pester et les TU n'importe ou.
     Write-Verbose "Check si le lecteur $DriveLetter est d�j� utilis�."
     if (Test-Path $DriveLetter) {
        Write-Error "Le lecteur $DriveLetter ne doit pas �tre d�j� pr�sent. \n Afin d'�viter des erreurs de copie, l'ex�cution de ce script va s'arr�ter."
        exit 1
     }



      # Ex�cution des tests Pester
     # On importe le module dans la session courante
     Write-verbose "Import du module Pester et ex�cution des tests d'infra sur $Target."

    
        # On se place dans le r�pertoire Pester pour pouvoir lancer les tests
 	    cd "$source\TestsPester"

        # On importe le framework Pester
 	    Import-Module "$($objForRemote.IISRoot)\Pester\Pester.psm1" 
        Import-Module "$($objForRemote.IISRoot)\Remotely\Remotely.psm1"

        # On ex�cute les tests
 	    Invoke-Pester -verbose -OutputFile $OutFile -OutputFormat NUnitXml `                      -EnableExit -Script @{ Path = "$Source\TestsPester"; Parameters = @{LifePage = $LifePage;
                                                             IISSite = $IISSite;
                                                             IISPool = $IISPool;
                                                             ApplicationVersion = $ApplicationVersion;
                                                             ApplicationName = $ApplicationName};}
 
     # Connexion au partage r�seau pour r�cup�rer le fichier XML
     Write-Verbose "Connexion au lecteur r�seau $DriveLetter mapp� sur \\$Target\d$"
     $net = new-object -ComObject WScript.Network
     $net.MapNetworkDrive($DriveLetter, "\\$Target\d$")
 
     # COpie du fichier de r�sultat des tests Pester
     Copy-Item -Path "$DriveLetterInetpub\collecte-rmoe-ccv-poc\TestsPester\$OutFile" -Destination "$Source\$OutFile"
 
     # D�connexion du lecteur r�seau
     Write-Verbose "D�connexion du lecteur r�seau $DriveLetter"
     $net.RemoveNetworkDrive($DriveLetter)
 }
 Catch {
    Write-Output "Test"
    Exit 1
 }