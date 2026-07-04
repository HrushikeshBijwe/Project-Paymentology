$path = 'modules\networking\main.tf'
$text = Get-Content -Raw -LiteralPath $path

# Replace aws_eip block (single regional EIP)
$pattern_eip = '(?s)resource "aws_eip" "nat" \{.*?\n\}'
$replacement_eip = 'resource "aws_eip" "nat" {\n  domain = "vpc"\n\n  tags = merge(\n    var.tags,\n    {\n      Name = "${var.project_name}-nat-eip"\n    }\n  )\n}\n'
$text = [regex]::Replace($text, $pattern_eip, $replacement_eip)

# Replace aws_nat_gateway block (single regional NAT)
$pattern_nat = '(?s)resource "aws_nat_gateway" "paymentology_nat" \{.*?\n\}'
$replacement_nat = 'resource "aws_nat_gateway" "paymentology_nat" {\n  allocation_id = aws_eip.nat.id\n  subnet_id     = aws_subnet.public[0].id\n\n  tags = merge(\n    var.tags,\n    {\n      Name = "${var.project_name}-nat"\n    }\n  )\n\n  depends_on = [aws_internet_gateway.paymentology_igw]\n}\n'
$text = [regex]::Replace($text, $pattern_nat, $replacement_nat)

# Update private route nat_gateway_id references
$text = $text -replace 'nat_gateway_id = aws_nat_gateway.paymentology_nat\[count.index\]\.id','nat_gateway_id = aws_nat_gateway.paymentology_nat.id'

Set-Content -LiteralPath $path -Value $text
Write-Output "Updated $path"
Select-String -Path $path -Pattern 'aws_nat_gateway.paymentology_nat\[|aws_eip.nat\[|nat-eip-' -NotMatch | Out-Null

# Show a snippet
Get-Content -LiteralPath $path -TotalCount 220 | Select-Object -First 220 | Out-String | Write-Output
