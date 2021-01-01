[array]$MiningRecourcesDatabase = Import-Csv -Path .\MiningRecourcesDatabase.csv
$ItemsLibrary = (Invoke-WebRequest -Uri https://api.eve-echoes-market.com/market-stats/stats.csv).Content | ConvertFrom-Csv
Function Calculate-Mining
{
param([int]$SpaceShipeOreStorage,[array]$ItemsLibrary,[array]$RecourcesDatabase)
    foreach ($Ore in $RecourcesDatabase)
    {
        [array]$Results += @([pscustomobject]@{Ore=$($Ore.Name);
                                       Volume_m3=$($Ore.Volume_m3);
                                       MarketID=$($Ore.MarketID);
                                       Sell=[int]$(($ItemsLibrary | where {$_.item_id -eq $Ore.MarketID}).sell);
                                       Buy=[int]$(($ItemsLibrary | where {$_.item_id -eq $Ore.MarketID}).buy);
                                       Lowest_sell=[int]$(($ItemsLibrary | where {$_.item_id -eq $Ore.MarketID}).lowest_Sell);
                                       Highest_Buy=[int]$(($ItemsLibrary | where {$_.item_id -eq $Ore.MarketID}).highest_Buy);
                                       Time = $(($ItemsLibrary | where {$_.item_id -eq $Ore.MarketID}).time);
                                       })
    
    }
    Foreach($ParsedOre in $Results)
    {
        $OreAmount = $SpaceShipeOreStorage / $($ParsedOre.Volume_m3)
        $MaxProfit = $OreAmount * $($ParsedOre.highest_buy)
        $AverageProfit = $OreAmount * $($ParsedOre.Buy)
        $CalculatedProfit += @([pscustomobject]@{Ore=$($ParsedOre.Ore);
                                                MaxIncome = $($MaxProfit);
                                                AverageIncome = $($AverageProfit);
                                                Time = $($ParsedOre.Time)
        })
    }
    return $CalculatedProfit

}
function Show-Menu {
    param (
        [string]$Title = 'Eve Echoes Profit calculator'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to calculate profit from asterod mining"
    Write-Host "Q: Press 'Q' to quit."
}
do
{
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
        '1' 
        {
            cls
            [int]$SpaceShipeOreStorage = Read-host 'Press input your space ship ore storage'
            [array]$Profit = @()
            $Profit = Calculate-Mining -SpaceShipeOreStorage $SpaceShipeOreStorage -ItemsLibrary $ItemsLibrary -RecourcesDatabase $MiningRecourcesDatabase
            cls
            Write-Output "Based on prices at https://eve-echoes-market.com/"
            Write-Output "Your Income with Space ship ore storage: $($SpaceShipeOreStorage) (per 1 run)"
            Write-Output $Profit | select -Property Ore, MaxIncome, AverageIncome | Sort-Object -Property AverageIncome | out-host
            pause
            #Read-Host 'PRess any key to return to main menu'
        }
        '2' 
        {
            'You chose option #2'
        }
    }
}until($selection -eq 'q')



