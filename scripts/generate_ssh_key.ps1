Param(
  [string]$KeyName = "${env:PROJECT_NAME:-paymentology}-ssh-key",
  [string]$OutDir = "$PSScriptRoot\..\.ssh",
  [string]$TfVars = "$PSScriptRoot\..\terraform.tfvars"
)

# Ensure output directory exists
if (-not (Test-Path -Path $OutDir)) {
  New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

$PrivateKeyPath = Join-Path $OutDir $KeyName
$PublicKeyPath = "$PrivateKeyPath.pub"

if (-not (Test-Path -Path $PrivateKeyPath)) {
  if (Get-Command ssh-keygen -ErrorAction SilentlyContinue) {
    Write-Host "Generating SSH key pair at $PrivateKeyPath"
    ssh-keygen -t rsa -b 4096 -f $PrivateKeyPath -N "" | Out-Null
  } else {
    Write-Error "ssh-keygen not found in PATH. Install OpenSSH client or run on a machine with ssh-keygen available."
    exit 1
  }
} else {
  Write-Host "SSH private key already exists at $PrivateKeyPath — skipping generation."
}

if (-not (Test-Path -Path $PublicKeyPath)) {
  Write-Error "Public key not found at $PublicKeyPath"
  exit 1
}

$pub = Get-Content -Path $PublicKeyPath -Raw

# Normalize TFVARS path
$TfVarsPath = Resolve-Path -Path $TfVars -ErrorAction SilentlyContinue
if (-not $TfVarsPath) { $TfVarsPath = $TfVars }

Write-Host "Injecting SSH public key into $TfVarsPath"

if (Test-Path -Path $TfVarsPath) {
  $content = Get-Content -Path $TfVarsPath -Raw

  if ($content -match '(?m)^[ \t]*ssh_public_key\s*=') {
    $content = $content -replace '(?m)^[ \t]*ssh_public_key\s*=.*', "ssh_public_key = `"$pub`""
  } else {
    $content = $content.TrimEnd() + "`nssh_public_key = `"$pub`"`n"
  }

  if ($content -match '(?m)^[ \t]*ssh_key_name\s*=') {
    $content = $content -replace '(?m)^[ \t]*ssh_key_name\s*=.*', "ssh_key_name = `"$KeyName`""
  } else {
    $content = $content.TrimEnd() + "ssh_key_name = `"$KeyName`"`n"
  }

  Set-Content -Path $TfVarsPath -Value $content -Force
} else {
  $tf = "ssh_public_key = `"$pub`"`nssh_key_name = `"$KeyName`"`n"
  Set-Content -Path $TfVarsPath -Value $tf -Force
}

Write-Host "Done. Public key injected. Private key: $PrivateKeyPath"