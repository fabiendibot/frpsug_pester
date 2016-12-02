param (
    [String]$IISSite,
    [String]$IISPool
)

Describe "ValidateIIS" {
    
    # Check if IIS is installed
    It "IIS Service Started" {
         (Get-Service W3SVC).Status | Should be "Running"
    }

    # Check if Website is created
    It "IIS Web Site started" {
          (Get-Website -Name $IISSite).State | Should be "Started"
    }
    
    # Check if Application exsists
    It "IIS Application Pool Started" {
         (Get-WebAppPoolState -name $IISPool).Value | Should be "Started"
    }
}
