[CmdletBinding()]
<#
.SYNOPSIS
Ce script lance des tests Pester avec Jenkins
 
.DESCRIPTION
Ce script par le biais d'une connexion WinRM va lancer l'import du module Pester pour faire des tests unitaires sur la configuration du IIS.
Une fois le module importé, il lance les tests qui sont dans sont répertoire courant, puis génère un rapport au format XML NUnit que Jenkins 
est capable d'interpréter pour donner des informations fiables sur l'état du déploiement.
Ce rapport sera situé dans le chemin correspondant à la variable $Source.

Pour lancer ce script dans Jenkins:

 
.PARAMETER Source
Correspond à la variable %WORKPLACE% dans Jenkins.
 
.PARAMETER Target
C'est le serveur IIS sur lequel vous voulez jouer les tests.

.PARAMETER IISRoot
Correspond à la racine du site IIS à tester.

.PARAMETER LifePage
URL de la page de vie à tester

.PARAMETER IISSite
Nom du site web à tester avec Pester

.PARAMETER IISPool
Nom du pool d'application qui contient le site web pour le tester avec Pester

.PARAMETER TestName
Correspond au nom du jeu de tests à jouer.

.PARAMETER ApplicationVersion
Version de l'application qui doit être testé avec Pester

.PARAMETER ApplicationName
Nom de l'application qui doit être testé avec Pester

.PARAMETER OutFile
Correspond au nom du fichier du rapport XML qui va être généré.

.PARAMETER DriveLetter
Correspond à la lettre du lecteur réseau temporaire qui va être créé pour copier le fichier XML de résultat.
 

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
     # Vérification si le lecteur $Driveletter n'est pas déjà utilisé et qu'on ne copie pas le framework Pester et les TU n'importe ou.
     Write-Verbose "Check si le lecteur $DriveLetter est déjà utilisé."
     if (Test-Path $DriveLetter) {
        Write-Error "Le lecteur $DriveLetter ne doit pas être déjà présent. \n Afin d'éviter des erreurs de copie, l'exécution de ce script va s'arrêter."
        exit 1
     }



      # Exécution des tests Pester
     # On importe le module dans la session courante
     Write-verbose "Import du module Pester et exécution des tests d'infra sur $Target."

    
        # On se place dans le répertoire Pester pour pouvoir lancer les tests
 	    cd "$source\TestsPester"

        # On importe le framework Pester
 	    Import-Module "$($objForRemote.IISRoot)\Pester\Pester.psm1" 
        Import-Module "$($objForRemote.IISRoot)\Remotely\Remotely.psm1"

        # On exécute les tests
 	    Invoke-Pester -verbose -OutputFile $OutFile -OutputFormat NUnitXml `                      -EnableExit -Script @{ Path = "$Source\TestsPester"; Parameters = @{LifePage = $LifePage;
                                                             IISSite = $IISSite;
                                                             IISPool = $IISPool;
                                                             ApplicationVersion = $ApplicationVersion;
                                                             ApplicationName = $ApplicationName};}
 
     # Connexion au partage réseau pour récupérer le fichier XML
     Write-Verbose "Connexion au lecteur réseau $DriveLetter mappé sur \\$Target\d$"
     $net = new-object -ComObject WScript.Network
     $net.MapNetworkDrive($DriveLetter, "\\$Target\d$")
 
     # COpie du fichier de résultat des tests Pester
     Copy-Item -Path "$DriveLetterInetpub\collecte-rmoe-ccv-poc\TestsPester\$OutFile" -Destination "$Source\$OutFile"
 
     # Déconnexion du lecteur réseau
     Write-Verbose "Déconnexion du lecteur réseau $DriveLetter"
     $net.RemoveNetworkDrive($DriveLetter)
 }
 Catch {
    Write-Output "Test"
    Exit 1
 }