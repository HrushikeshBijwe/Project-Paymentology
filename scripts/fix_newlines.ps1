$p='modules\networking\main.tf'
$t=Get-Content -Raw -LiteralPath $p
$t=$t.Replace('\n',[Environment]::NewLine)
Set-Content -LiteralPath $p -Value $t
Write-Output "done"
Get-Content -LiteralPath $p -TotalCount 220 | Out-String | Write-Output
