$MicrosoftCallingPlanName = [PSCustomObject][Ordered]@{
    Name = "MCOPSTN1"
    UserMonthPrice  = [decimal]"11.64"
    MinutePerMonth = [int]"3000" 
},
[PSCustomObject][Ordered]@{
    Name = "MCOPSTN2"
    UserMonthPrice = [int]"24"
    MinutePerMonth = [int]"3000"
},[PSCustomObject][Ordered]@{
    Name = "MCOPSTN5"
    UserMonthPrice = [decimal]"5.83"
    MinutePerMonth = [int]"120"
},[PSCustomObject][Ordered]@{
    Name = "MCOPSTN6"
    UserMonthPrice = [decimal]"7.76"
    MinutePerMonth = [int]"240"
}

$CiscoCallingPlan = [PSCustomObject][Ordered]@{
    Name = "CER"
    UserMonthPrice = [decimal]"0.2"
},[PSCustomObject][Ordered]@{
    Name = "CUCM"
    UserMonthPrice = [decimal]"4.17"
}

    