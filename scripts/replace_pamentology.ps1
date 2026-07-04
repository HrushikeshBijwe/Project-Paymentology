$files = Get-ChildItem -Path .\modules -Filter *.tf -Recurse
foreach ($f in $files) {
  $path = $f.FullName
  $text = Get-Content -LiteralPath $path -Raw
  $new = $text -replace 'pamentology_','paymentology_'
  if ($text -ne $new) { Set-Content -LiteralPath $path -Value $new }
}

Select-String -Path .\modules\**\*.tf -Pattern 'pamentology_' | Measure-Object
