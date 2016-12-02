param (
    [String]$LifePage,
    [String]$IISSite,
    [String]$IISPool,
    [String]$ApplicationVersion,
    [String]$ApplicationName
)

Describe "ValidateCCV" {
    
    #Import-Module webadministration

    # Récupération des variables dans le fichier .xml
        
    $Result  = Invoke-WebRequest -Uri $LifePage

    # Check if IIS is installed
    It "IIS Service Started" {
        Remotely { (Get-Service W3SVC).Status } | Should be "Running"
    }

    # Check if Website is created
    It "IIS Web Site started" {
        Remotely { param($IISSite) (Get-Website -Name $IISSite).State } -ArgumentList $IISSite | Should be "Started"
    }
    
    # Check if Application exsists
    It "IIS Application Pool Started" {
        Remotely { (Get-WebAppPoolState -name $IISPool).Value } | Should be "Started"
    }

    # Check application version
    It "Application version" {
        Remotely { param($Result) ($Result.AllElements | ? { $_.id -eq 'applicationVersion' }).outerText } -ArgumentList $Result | Should be $($ApplicationVersion)
    }

    # Check Application Name
    It "Application Name" {
        Remotely { param($Result) ($Result.AllElements | ? { $_.id -eq 'NomApplication' }).outerText } -ArgumentList $Result | Should be $($ApplicationName)
    }

    # Check Database Connexion
    It "Database Connexion" {
        Remotely { param($Result) ($Result.AllElements | ? { $_.id -eq 'testAppelBdd' }).outerText } -ArgumentList $Result | Should be 'KO'
    }

}
