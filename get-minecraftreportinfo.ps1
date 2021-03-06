Import-Csv "c:\MINECRAFTLISTnew.csv" | where {$_.complianceState -like "Compliant" -or $_.ComplianceState -like "Non-Compliant"} | Export-Csv "C:\Users\emdanyi\Desktop\MinecraftMachinesPollednew.csv"

Import-Csv "c:\MINECRAFTLISTnew.csv" | where {$_.complianceState -like "Non-Compliant"} | Export-Csv ".\MachinesWithMinecraftnew.csv"

Import-Csv "c:\MINECRAFTLISTnew.csv" | where {$_.ComplianceState -like "Non-Compliant" -and $_.DeviceName -like "*-*"} | Export-Csv "c:\Users\emdanyi\Desktop\StaffMinecraftnew.csv"

Import-Csv "c:\MINECRAFTLISTnew.csv" | where {$_.ComplianceState -like "Non-Compliant" -and $_.DeviceName -notlike "*-*"} | Export-Csv "c:\Users\emdanyi\Desktop\StudentMinecraftnew.csv"
