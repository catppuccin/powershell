<h3 align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/logos/exports/1544x1544_circle.png" width="100" alt="Logo"/><br/>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
	Catppuccin for <a href="https://github.com/PowerShell/PowerShell">PowerShell</a>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
</h3>

<p align="center">
	<a href="https://github.com/JK-Flip-Flop96/powershell/stargazers"><img src="https://img.shields.io/github/stars/catppuccin/powershell?colorA=363a4f&colorB=b7bdf8&style=for-the-badge"></a>
	<a href="https://github.com/JK-Flip-Flop96/powershell/issues"><img src="https://img.shields.io/github/issues/catppuccin/powershell?colorA=363a4f&colorB=f5a97f&style=for-the-badge"></a>
	<a href="https://github.com/JK-Flip-Flop96/powershell/contributors"><img src="https://img.shields.io/github/contributors/catppuccin/powershell?colorA=363a4f&colorB=a6da95&style=for-the-badge"></a>
</p>

## Usage

1. Clone this repository locally.
2. Place the contents of the repository in a folder named `Catppuccin` in a folder on your PowerShell Module Path. You can find your current PowerShell Module Path by running `$env:PSModulePath` in PowerShell.
3. Import the module by running `Import-Module Catppuccin` in PowerShell. You can also add this to your PowerShell profile to automatically import the module when you start PowerShell. This may be useful if you want to use Catppuccin in your prompt.
4. Start using the module! Help is available by running `Get-Help Catppuccin`.

## Examples

### Basic Usage

Import the module and get a flavor by name:

```powershell
# Import the module
Import-Module Catppuccin

# Set a flavor for easy access
$Flavor = $Catppuccin['Mocha']

# Print a summary of the flavor's colors
# Returns Null, calls Write-Host internally.
$Flavor.Table()

# Print blocks of the flavor's colors
# Returns a string
Write-Host $Flavor.Blocks()
```

Access the colors of a flavor in various formats:
```powershell
# Get the hex value of the flavor's Red color
$Flavor.Red.Hex()
# Returns a string of the hex value
# Also accessible with $Flavor.Red in contexts where the object is converted to a string

# Get the RGB value of the flavor's Green color
$Flavor.Green.RGB() 
# Returns an array of RGB values
# Can also be accessed by $Flavor.Green.Red, $Flavor.Green.Green, and $Flavor.Green.Blue

# Get the HSL value of the flavor's Blue color
$Flavor.Blue.HSL() 
# Returns an array of HSL values

# Get an ANSI Foreground Color Escape sequence for the flavor's Yellow color
$Flavor.Yellow.Foreground()
# Returns a string of the ANSI Escape sequence

# Get a ANSI Background Escape sequence for the flavor's Teal color
$Flavor.Teal.Background()
# Returns a string of the ANSI Escape sequence
```

### $PROFILE Usage
The following examples are for using Catppuccin in your PowerShell profile. You can find your PowerShell profile by running `$PROFILE` in PowerShell. If you don't have a profile, you can create one by running `New-Item -Path $PROFILE -ItemType File -Force`.

Note that these examples assume that you have already imported the module earlier in your profile and assigned a flavor to the variable `$Flavor` as shown in the previous example.

Usage in a prompt:
```powershell
# Modified from the built-in prompt function at: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts
function prompt {
    $(if (Test-Path variable:/PSDebugContext) { "$($Flavor.Red.Foreground())[DBG]: " }
      else { '' }) + "$($Flavor.Teal.Foreground())PS $($Flavor.Yellow.Foreground())" + $(Get-Location) +
        "$($Flavor.Green.Foreground())" + $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> ' + $($PSStyle.Reset)
}
# The above example requires the automatic variable $PSStyle to be available, so can be only used in PS 7.2+
# Replace $PSStyle.Reset with "`e[0m" for PS 6.0 through PS 7.1 or "$([char]27)[0m" for PS 5.1
```

Usage for configuring another program's environment variables: (e.g. [fzf](https://github.com/junegunn/fzf))

```powershell
# Modified from the official Catppuccin fzf configuration at: https://github.com/catppuccin/fzf/
$ENV:FZF_DEFAULT_OPTS = @"
--color=bg+:$($Flavor.Surface0),bg:$($Flavor.Base),spinner:$($Flavor.Rosewater)
--color=hl:$($Flavor.Red),fg:$($Flavor.Text),header:$($Flavor.Red)
--color=info:$($Flavor.Mauve),pointer:$($Flavor.Rosewater),marker:$($Flavor.Rosewater)
--color=fg+:$($Flavor.Text),prompt:$($Flavor.Mauve),hl+:$($Flavor.Red)
--color=border:$($Flavor.Surface2)
"@
```

Usage for configuring another Module's options: (e.g. [PSReadLine](https://github.com/PowerShell/PSReadLine))

```powershell
$Colors = @{
	# Largely based on the Code Editor style guide
	# Emphasis, ListPrediction and ListPredictionSelected are inspired by the Catppuccin fzf theme
	
	# Powershell colours
	ContinuationPrompt     = $Flavor.Teal.Foreground()
	Emphasis               = $Flavor.Red.Foreground()
	Selection              = $Flavor.Surface0.Background()
	
	# PSReadLine prediction colours
	InlinePrediction       = $Flavor.Overlay0.Foreground()
	ListPrediction         = $Flavor.Mauve.Foreground()
	ListPredictionSelected = $Flavor.Surface0.Background()

	# Syntax highlighting
	Command                = $Flavor.Blue.Foreground()
	Comment                = $Flavor.Overlay0.Foreground()
	Default                = $Flavor.Text.Foreground()
	Error                  = $Flavor.Red.Foreground()
	Keyword                = $Flavor.Mauve.Foreground()
	Member                 = $Flavor.Rosewater.Foreground()
	Number                 = $Flavor.Peach.Foreground()
	Operator               = $Flavor.Sky.Foreground()
	Parameter              = $Flavor.Pink.Foreground()
	String                 = $Flavor.Green.Foreground()
	Type                   = $Flavor.Yellow.Foreground()
	Variable               = $Flavor.Lavender.Foreground()
}

# Set the colours
Set-PSReadLineOption -Colors $Colors
```
Usage for configuring PowerShell defaults:

```powershell
# The following colors are used by PowerShell's formatting
# Again PS 7.2+ only
$PSStyle.Formatting.Debug = $Flavor.Sky.Foreground()
$PSStyle.Formatting.Error = $Flavor.Red.Foreground()
$PSStyle.Formatting.ErrorAccent = $Flavor.Blue.Foreground()
$PSStyle.Formatting.FormatAccent = $Flavor.Teal.Foreground()
$PSStyle.Formatting.TableHeader = $Flavor.Rosewater.Foreground()
$PSStyle.Formatting.Verbose = $Flavor.Yellow.Foreground()
$PSStyle.Formatting.Warning = $Flavor.Peach.Foreground()
```

## 📝 Notes

- This Module does not set your terminal's color scheme. You will need to do this yourself. (e.g. [Catppuccin for Windows Terminal](https://github.com/catppuccin/windows-terminal))
- Usage of the Foreground and Background colors requires support for ANSI Escape Sequences and 24-bit color (truecolor) in your terminal. See [this article](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_ansi_terminals) for more information.

## 💝 Thanks to

- [Stuart Miller](https://github.com/JK-Flip-Flop96)

&nbsp;

<p align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" />
</p>

<p align="center">
	Copyright &copy; 2021-present <a href="https://github.com/catppuccin" target="_blank">Catppuccin Org</a>
</p>

<p align="center">
	<a href="https://github.com/catppuccin/catppuccin/blob/main/LICENSE"><img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logoColor=d9e0ee&colorA=363a4f&colorB=b7bdf8"/></a>
</p>
