$maxjob = 2
#$count = 0
$Files = Import-Csv C:\testLV.csv
function Test-MVLV {
    
        $JbID = [System.Guid]::NewGuid()
        $vm = Get-SCVirtualMachine -Name $file.vmname
        $vmnetwork = Get-SCVirtualNetworkAdapter -VM $vm.name | `
        Select-Object Slotid,VMNetwork,VirtualNetwork,Macaddress,MacaddressType,IPv4AddressType,IPv6AddressType,id,portclassification

        foreach ($vmnet in $vmnetwork.Slotid)
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
    -UseLAN -RunAsynchronously -UseDiffDiskOptimization -JobGroup $Guid -Path $storageDesPath
    #$count++
    }
foreach ($file in $Files)
{
    $running = (Get-SCJob | where-object{$_.status -eq "Running" -and ($_.Name -like "Live*" -or $_.Name -like "Move*") -and $_.Owner -eq "mgmtwap\..."}).count
    $่jobcnt = (Get-SCJob | where-object{$_.status -eq "Completed" -and ($_.Name -like "Live*" -or $_.Name -like "Move*") -and $_.Owner -eq "mgmtwap\..."}).count
    if ($running -le $maxjob)
    {
       # write-host "Start Live-migration..."
        Test-MVLV
    }
    elseif ($่jobcnt -eq $maxjob) 
    {
        Get-SCJob | where-object{$_.status -eq "Completed" -and ($_.Name -like "Live*" -or $_.Name -like "Move*") -and $_.Owner -eq "mgmtwap\..."} | Sort-Object ID | select-object ID,Name,status | `
        export-csv <#Path collecting LV JOB#>
        Test-MVLV #cont. run live migration
    }
}