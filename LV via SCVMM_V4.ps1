$maxjob = 2
$i = 0
$running = 0
$jobcnt = 0
$Files = Import-Csv C:\Scripts\testLV.csv
function Test-MVLV {
    
        $JbID = [System.Guid]::NewGuid()
        $vm = Get-SCVirtualMachine -Name $file.vmname
        $vmHost = Get-SCVMHost | where { $_.Name -eq $file.hostdest}
        $storageDesPath = $file.lundest
        $vmnetwork = Get-SCVirtualNetworkAdapter -VM $vm.Name <#| `
        Select-Object Slotid,VMNetwork,VirtualNetwork,Macaddress,MacaddressType,IPv4AddressType,IPv6AddressType,id,portclassification #>

        foreach ($vmnet in $vmnetwork<#.Slotid#>)
        {
    
     Set-SCVirtualNetworkAdapter -VirtualNetworkAdapter $vmnet -VirtualNetwork $vmnet.VirtualNetwork -VMNetwork $vmnet.vmNetwork `
     -PortClassification $vmnet.portClassification `
     -EnableVMNetworkOptimization $false -EnableMACAddressSpoofing $false `
     -MACAddressType $vmnet.MACAddressType -MACAddress $vmnet.MACAddress `
     -IPv4AddressType $vment.IPv4AddressType -IPv6AddressType $vmnet.IPv6AddressType `
     -RunAsynchronously -JobGroup $JbID
        }
        #=============================== Start Live Migration =========================================#
    Move-SCVirtualMachine -VM $vm -VMHost $vmHost -HighlyAvailable $true `
    -UseLAN -RunAsynchronously -UseDiffDiskOptimization -JobGroup $JbID -Path $storageDesPath

    }
foreach ($file in $Files)
{
    $running = (Get-SCJob | where-object{$_.status -eq "Running" -and ($_.Name -like "Live*" -or $_.Name -like "Move*") -and $_.Owner -eq "mgmtwap\sutticha"}).count
    $jobcnt = (Get-SCJob | where-object{$_.status -eq "Completed" -and ($_.Name -like "Live*" -or $_.Name -like "Move*") -and $_.Owner -eq "mgmtwap\sutticha"}).count
    if ($running -gt $maxjob)
    {
       # write-host "Start Live-migration..."
        Test-MVLV
    }
    <#elseif ($jobcnt -eq $maxjob) 
    {   $i++
        $export = "C:\Scripts\LVReport\lvreport"+$i+".csv"
        Get-SCJob | where-object{$_.status -eq "Completed" -and ($_.Name -like "Live*" -or $_.Name -like "Move*") -and $_.Owner -eq "mgmtwap\sutticha"} | Sort-Object ID | select-object ID,Name,status | `
        export-csv $export -Encoding UTF8 -NoTypeInformation
        #Test-MVLV #cont. run live migration
    }#>
}