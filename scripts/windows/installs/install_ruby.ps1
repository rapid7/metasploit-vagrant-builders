# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

choco install -y ruby --version 3.0.5.1
refreshenv
