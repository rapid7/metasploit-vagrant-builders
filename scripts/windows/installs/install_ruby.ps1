# Exit if a cmdlet fails
$ErrorActionPreference = "Stop"

choco install -y ruby --version 3.0.7.1
refreshenv
