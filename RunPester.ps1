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