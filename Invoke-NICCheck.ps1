function Invoke-NICCheck {
    [CmdletBinding(SupportsShouldProcess)]
    param (

        [string]$WiredTextFile = "$Env:SystemDrive\GCS2GOResults\Wired.txt",

        [string]$WirelessTextFile = "$Env:SystemDrive\GCS2GOResults\Wireless.txt",

        [string]$testSite = 'google.com'

    )
    
    begin {

        if ((Test-Path $WiredTextFile) -eq $false) {
            New-Item -Path $WiredTextFile -ItemType 'File' -Force -ErrorAction Stop
        }

        if ((Test-Path $WirelessTextFile) -eq $false) {
            New-Item -Path $WirelessTextFile -ItemType 'File' -Force -ErrorAction Stop
        }

    }
    
    process {

        $physicalNetAdapters = Get-NetAdapter -Physical
        
        foreach ($physicalNetAdapter in $physicalNetAdapters) {

            switch ($physicalNetAdapter.PhysicalMediaType) {

                {$_ -match "802.3"} {

                    # Wired match
                    Write-Output "Wired match!"

                    switch ($physicalNetAdapter.Status) {

                        "Up" {

                            # Up match
                            Write-Output "`tMedia is up!"

                            # Invoke the function that performs the ping test
                            $pingTestResult = Invoke-PingTester -InterfaceAlias $physicalNetAdapter.InterfaceAlias -TestSite $TestSite

                            # Write result
                            if ($pingTestResult -eq $true) {

                                # Ping test was good
                                Write-Output "`t`tPing was good!"
                                Set-Content -Path $WiredTextFile -Value 'Good' -NoNewline

                            } else {

                                # Ping test failed
                                Write-Output "`t`tPing failed!"
                                Set-Content -Path $WiredTextFile -Value 'NIC is good, no ping response' -NoNewline

                            }
                            
                        }

                        Default {

                            # Non-'up' status match
                            Write-Output "`tMedia disconnected or other status!"
                            Set-Content -Path $WiredTextFile -Value 'Needs attention' -NoNewline

                        }

                    }

                }

                {$_ -match "802.11"} {

                    # Wireless match
                    Write-Output "Wireless match!"

                    switch ($physicalNetAdapter.Status) {

                        "Up" {

                            # Invoke the function that performs the ping test
                            $pingTestResult = Invoke-PingTester -InterfaceAlias $physicalNetAdapter.InterfaceAlias -TestSite $TestSite

                            # Write result
                            if ($pingTestResult -eq $true) {

                                # Ping test was good
                                Write-Output "`t`tPing was good!"
                                Set-Content -Path $WirelessTextFile -Value 'Good' -NoNewline

                            } else {

                                # Ping test failed
                                Write-Output "`t`tPing failed!"
                                Set-Content -Path $WirelessTextFile -Value 'NIC is good, no ping response' -NoNewline

                            }
                            
                        }

                        Default {

                            # Non-'up' status match
                            Write-Output "`tMedia disconnected or other status!"
                            Set-Content -Path $WirelessTextFile -Value 'Needs attention' -NoNewline

                        }

                    }

                }

                Default {

                    # No wired or wireless NIC detected
                    Set-Content -Path $WiredTextFile -Value 'No wired or wireless NIC detected.' -NoNewline
                    Set-Content -Path $WirelessTextFile -Value 'No wired or wireless NIC detected.' -NoNewline

                }

            }

        }

    }
    
    end {}
}

function Invoke-PingTester {
    [CmdletBinding(SupportsShouldProcess)]
    param (

        # $physicalNetAdapter.InterfaceAlias
        [string]$InterfaceAlias,

        # TestSite from main function
        [string]$TestSite

    )
    
    begin {}
    
    process {

        # Get the default gateway
        $defaultgateway = (Get-NetIPConfiguration -InterfaceAlias $InterfaceAlias).IPv4DefaultGateway.NextHop

        # Get the net adapter's IP address
        $ip = (Get-NetIPConfiguration -InterfaceAlias $InterfaceAlias).IPv4Address.IPAddress

        # Ping test
        if (($null -ne $defaultgateway) -and ($null -ne $ip)) {

            # Default gateway and IP detected
            $pingTest = cmd.exe /c ping -n 1 -S $ip $defaultgateway

            if ($pingTest -match "Reply from") {

                # Matched "Reply from .....", so likely a successful ping. Change appropriately.
                $pingTest = $true

            } else {

                # Likely shows "Request timed out."
                $pingTest = $false

            }

        } elseif ($null -ne $ip) {

            # Default gateway not detected, trying test site
            $pingTest = cmd.exe /c ping -n 1 -S $ip $TestSite

            if ($pingTest -match "Reply from") {

                # Matched "Reply from .....", so likely a successful ping. Change appropriately.
                $pingTest = $true

            } else {

                # Likely shows "Request timed out."
                $pingTest = $false

            }

        } else {

            # Default gateway and IP not detected, return false
            $pingTest = $false

        }

    }
    
    end {

        # Output result
        Write-Output -InputObject $pingTest

    }
}
