# SetupX - Main Entry Point
# Modular Windows Development Environment Setup Tool

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Import the main CLI
. "$ScriptDir\src\cli\setupx-cli.ps1" @args
