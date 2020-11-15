# Net Adapter Test

The use case of this script is for a specific scenario in which all devices have only a single wireless network card, or only a single wired network card, or only one of each. The result of the test is outputted to a text file.

If anyone else chooses to use these functions and your hardware has more than one of the same type of network adapter, the functions will require some modifications to address that. If anyone has the desire to improve upon the script, I'll accept pull requests.

## Examples

### Example 1
``` powershell
Invoke-NICCheck -WhatIf
```

### Example 2
``` powershell
Invoke-NICCheck -WiredTextFile "$Env:SystemDrive\GCS2GOResults\Wired.txt" -WirelessTextFile "$Env:SystemDrive\GCS2GOResults\Wireless.txt" -testSite "google.com" -WhatIf
```

### Example 3
``` powershell
Invoke-NICCheck -WiredTextFile "$Env:SystemDrive\GCS2GOResults\Wired.txt" -WirelessTextFile "$Env:SystemDrive\GCS2GOResults\Wireless.txt" -testSite "google.com"
```

### Example 4
``` powershell
Invoke-NICCheck
```

## Notes
 1. Initially I used `Test-Connection`, but it did not actually use the specified NIC to do the ping test unless I specified the `-Source` parameter. You can't use `-Source` with `-Quiet` parameter, and it doesn't work otherwise with a variable. So I had to use ping.exe and parsed that because I was too short on time to use a better workaround.
 2. Because this is using `Set-Content` instead of `Add-Content`, this will over-write the text file if there is more than one same NIC type (wired/wireless). So, you'll need to change that if you need it to append text to the file.
 3. This supports the `-WhatIf` switch so you can see what it will do before it does any kind of modifications.
 4. This main function uses the wired/wireless text file path and file name scheme that you used in your example, by default, but you can also specify them as parameters in the examples I show.
