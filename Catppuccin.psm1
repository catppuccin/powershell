class Colour {
    <#
    .SYNOPSIS
        A class to represent a colour
    .DESCRIPTION
        A class to represent a colour, with methods to return the RGB values, HSL values, hex code, 
        and ANSI escape sequences for foreground and background colours
    #>

    # Required Values
    [byte]$Red
    [byte]$Green
    [byte]$Blue

    # Calculated Values
    hidden [double]$Hue
    hidden [double]$Saturation
    hidden [double]$Lightness

    # Flags
    hidden [bool]$HasHSL = $false

    Colour([byte]$Red, [byte]$Green, [byte]$Blue) {
        <#
        .SYNOPSIS
            Creates a new colour object
        .PARAMETER Red
            The red value of the colour
        .PARAMETER Green
            The green value of the colour
        .PARAMETER Blue
            The blue value of the colour
        #>
        $this.Red = $Red
        $this.Green = $Green
        $this.Blue = $Blue
    }

    [byte[]]RGB() {
        <#
        .SYNOPSIS
            Returns the seperate RGB values for the colour   
        #>
        return @($this.Red, $this.Green, $this.Blue)
    }

    [string]RGBString() {
        <#
        .SYNOPSIS
            Returns the RGB values for the colour as a string
        #>
        return "$($this.Red), $($this.Green), $($this.Blue)"
    }

    [double[]]HSL() {
        <#
        .SYNOPSIS
            Returns the seperate HSL values for the colour

        .DESCRIPTION
            Returns the seperate HSL values for the colour
            HSL values are returned as an array of doubles, in the order of Hue, Saturation, and Lightness
            Hue is returned in degrees, from 0 to 360
            Saturation and Lightness are returned as a value in the range of 0 to 1

        .NOTES
            This method is based on the algorithm found at:
            https://www.had2know.org/technology/hsl-rgb-color-converter.html
        #>

        # Return the values if they have already been calculated
        if ($this.HasHSL) {
            return @($this.Hue, $this.Saturation, $this.Lightness)
        }

        # Convert to a value from 0 to 1
        $local:R = $this.Red / 255
        $local:G = $this.Green / 255
        $local:B = $this.Blue / 255

        # Calculate Max and Min values - Nested because Math.Min/Max only take 2 arguments
        $local:Max = [Math]::Max([Math]::Max($R, $G), $B)
        $local:Min = [Math]::Min([Math]::Min($R, $G), $B) 

        # Calculate Lightness
        $local:L = ($Max + $Min) / 2

        # Calculate Saturation - if/else to avoid divide by 0
        $local:S = if ($L -gt 0) { ($Max - $Min) / (1 - [Math]::Abs(2 * $L - 1)) } else { 0 }
        
        # Calculate Hue -> Convert to degrees - if/else to avoid NaN
        $local:H = if ($G -ne $B ) {
            [Math]::Acos(($R - $G / 2 - $B / 2) / 
                [Math]::Sqrt([Math]::Pow($R, 2) + [Math]::Pow($G, 2) + [Math]::Pow($B, 2) -
                    $R * $G - $R * $B - $G * $B)) * 180 / [Math]::PI
        } else {
            0
        }

        # Value above is only correct for H < 180, so we need to correct it for the blue half of the colour wheel
        if ($B -gt $G) {
            $H = 360 - $H 
        }

        # Set flag
        $this.HasHSL = $true

        # Cache values
        $this.Hue = $H
        $this.Saturation = $S
        $this.Lightness = $L

        return @($H, $S, $L)
    }

    [string]HSLString() {
        <#
        .SYNOPSIS
            Returns the HSL values for the colour as a formatted string
        
        .DESCRIPTION
            Returns the HSL values for the colour as a formatted string
            Hue is returned in degrees, from 0 to 360
            Saturation and Lightness are returned as a percentage, from 0 to 100
            All values are rounded to the nearest integer
        #>
        $local:HSL = $this.HSL()
        return "$([Math]::Round($HSL[0])), $([Math]::Round($HSL[1] * 100))%, $([Math]::Round($HSL[2] * 100))%"
    }

    [double[]]HSV() {
        <#
        .SYNOPSIS
            Returns the seperate HSV values for the colour
        
        .DESCRIPTION
            Returns the seperate HSV values for the colour
            HSV values are returned as an array of doubles, in the order of Hue, Saturation, and Value
            Hue is returned in degrees, from 0 to 360
            Saturation and Value are returned as a value in the range of 0 to 1
        #>

        # Derived from the HSL values
        $local:H, $local:S, $local:L = $this.HSL()

        # H = H
        $local:V = $L + $S * [Math]::Min($L, 1 - $L)
        $local:S = if ($V -ne 0) { 2 * (1 - $L / $V) } else { 0 }

        return @($H, $S, $V)
    }

    [string]HSVString() {
        <#
        .SYNOPSIS
            Returns the HSV values for the colour as a formatted string
        
        .DESCRIPTION
            Returns the HSV values for the colour as a formatted string
            Hue is returned in degrees, from 0 to 360
            Saturation and Value are returned as a percentage, from 0 to 100
            All values are rounded to the nearest integer
        #>
        $local:HSV = $this.HSV()
        return "$([Math]::Round($HSV[0])), $([Math]::Round($HSV[1] * 100))%, $([Math]::Round($HSV[2] * 100))%"
    }

    [double[]]CMYK() {
        <#
        .SYNOPSIS
            Returns the CMYK values for the colour

        .DESCRIPTION
            Returns the CMYK values for the colour
            CMYK values are returned as value from 0 to 1
        #>
        $local:R = $this.Red / 255
        $local:G = $this.Green / 255
        $local:B = $this.Blue / 255

        $local:K = 1 - [Math]::Max([Math]::Max($R, $G), $B)
        $local:C = if ($K -ne 1) { (1 - $R - $K) / (1 - $K) } else { 0 }
        $local:M = if ($K -ne 1) { (1 - $G - $K) / (1 - $K) } else { 0 }
        $local:Y = if ($K -ne 1) { (1 - $B - $K) / (1 - $K) } else { 0 }

        return @($C, $M, $Y, $K)
    }

    [string]Hex() {
        <#
        .SYNOPSIS
            Returns the hex code for the colour
        #>
        return "#$($this.Red.ToString('X2'))$($this.Green.ToString('X2'))$($this.Blue.ToString('X2'))"
    }

    [string]Foreground() {
        <#
        .SYNOPSIS
            Returns the ANSI Foreground escape sequence for the colour
        #>
        return "$([char]27)[38;2;$($this.Red);$($this.Green);$($this.Blue)m"
    }

    [string]Background() {
        <#
        .SYNOPSIS
            Returns the ANSI Background escape sequence for the colour
        #>
        return "$([char]27)[48;2;$($this.Red);$($this.Green);$($this.Blue)m"
    }

    [string]ToString() {
        <#
        .SYNOPSIS
            Returns the hex code for the colour
        #>
        return $this.Hex()
    }
}

class Flavour {
    <#
    .SYNOPSIS
        A class to represent a flavour of Catppuccin
    #>
    [Colour]$Rosewater
    [Colour]$Flamingo
    [Colour]$Pink
    [Colour]$Mauve
    [Colour]$Red
    [Colour]$Maroon
    [Colour]$Peach
    [Colour]$Yellow
    [Colour]$Green
    [Colour]$Teal
    [Colour]$Sky
    [Colour]$Sapphire
    [Colour]$Blue
    [Colour]$Lavender
    [Colour]$Text
    [Colour]$Subtext1
    [Colour]$Subtext0
    [Colour]$Overlay2
    [Colour]$Overlay1
    [Colour]$Overlay0
    [Colour]$Surface2
    [Colour]$Surface1
    [Colour]$Surface0
    [Colour]$Base
    [Colour]$Mantle
    [Colour]$Crust

    [string]Blocks() {
        <#
        .SYNOPSIS
            Prints a block for each colour in the flavour
        #>
        
        return $($this.psobject.Properties | Select-Object -ExpandProperty Name | ForEach-Object {
            "$($this.$_.Background())   "
        }) -Join '' + "$([char]27)[0m"
    }

    Table() {
        <#
        .SYNOPSIS
            Prints a table of the colours in the flavour

        .DESCRIPTION
            Prints a table of the colours in the flavour, with the colour name, hex code, RGB values, and HSL 
            values. It also prints a circle of the colour so you can see what it looks like

            The output is intended to mimic the tables in the README.md of the Catppuccin/Catppuccin repo
        #>

        $this.psobject.Properties | Select-Object -ExpandProperty Name |
            Select-Object -Property `
            @{Name = ' '; Expression = { "$($this.$_.Foreground())$([char]0x2B24)$([char]27)[0m" } }, 
            @{Name = 'Name'; Expression = { $_.ToString() } }, 
            @{Name = 'Hex'; Expression = { $this.$_.Hex() } }, 
            @{Name = 'RGB'; Expression = { "rgb($($this.$_.RGBString()))" } }, 
            @{Name = 'HSL'; Expression = { "hsl($($this.$_.HSLString()))" } } | 
            Format-Table -AutoSize | Out-Host
    }
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Variable is exported')]
$Catppuccin = @{
    'Latte'     = [Flavour]@{ 
        <# Latte Flavoured Catppuccin #>
        # Colours
        Rosewater = [Colour]::new(220, 138, 120)
        Flamingo  = [Colour]::new(221, 120, 120)
        Pink      = [Colour]::new(234, 118, 203)
        Mauve     = [Colour]::new(136, 57, 239)
        Red       = [Colour]::new(210, 15, 57)
        Maroon    = [Colour]::new(230, 69, 83)
        Peach     = [Colour]::new(254, 100, 11)
        Yellow    = [Colour]::new(223, 142, 29)
        Green     = [Colour]::new(64, 160, 43)
        Teal      = [Colour]::new(23, 146, 153)
        Sky       = [Colour]::new(4, 165, 229)
        Sapphire  = [Colour]::new(32, 159, 181)
        Blue      = [Colour]::new(30, 102, 245)
        Lavender  = [Colour]::new(114, 135, 253)

        # Greys
        Text      = [Colour]::new(76, 79, 105)
        Subtext1  = [Colour]::new(92, 95, 119)
        Subtext0  = [Colour]::new(108, 111, 133)
        Overlay2  = [Colour]::new(124, 127, 147)
        Overlay1  = [Colour]::new(140, 143, 161)
        Overlay0  = [Colour]::new(156, 160, 176)
        Surface2  = [Colour]::new(172, 176, 190)
        Surface1  = [Colour]::new(188, 192, 204)
        Surface0  = [Colour]::new(204, 208, 218)
        Base      = [Colour]::new(239, 241, 245)
        Mantle    = [Colour]::new(230, 233, 239)
        Crust     = [Colour]::new(220, 224, 232)
    }
    'Frappe'    = [Flavour]@{ 
        <# Frappe flavoured Catppuccin #>
        # Colours
        Rosewater = [Colour]::new(242, 213, 207)
        Flamingo  = [Colour]::new(238, 190, 190)
        Pink      = [Colour]::new(244, 184, 228)
        Mauve     = [Colour]::new(202, 158, 230)
        Red       = [Colour]::new(231, 130, 132)
        Maroon    = [Colour]::new(234, 153, 156)
        Peach     = [Colour]::new(239, 159, 118)
        Yellow    = [Colour]::new(229, 200, 144)
        Green     = [Colour]::new(166, 209, 137)
        Teal      = [Colour]::new(129, 200, 190)
        Sky       = [Colour]::new(153, 209, 219)
        Sapphire  = [Colour]::new(133, 193, 220)
        Blue      = [Colour]::new(140, 170, 238)
        Lavender  = [Colour]::new(186, 187, 241)

        # Greys
        Text      = [Colour]::new(198, 208, 245)
        Subtext1  = [Colour]::new(181, 191, 226)
        Subtext0  = [Colour]::new(165, 173, 206)
        Overlay2  = [Colour]::new(148, 156, 187)
        Overlay1  = [Colour]::new(131, 139, 167)
        Overlay0  = [Colour]::new(115, 121, 148)
        Surface2  = [Colour]::new(98, 104, 128)
        Surface1  = [Colour]::new(81, 87, 109)
        Surface0  = [Colour]::new(65, 69, 89)
        Base      = [Colour]::new(48, 52, 70)
        Mantle    = [Colour]::new(41, 44, 60)
        Crust     = [Colour]::new(35, 38, 52)
    }
    'Macchiato' = [Flavour]@{ 
        <# Macchiato Flavoured Catppuccin #>
        # Colours
        Rosewater = [Colour]::new(244, 219, 214)
        Flamingo  = [Colour]::new(240, 198, 198)
        Pink      = [Colour]::new(245, 189, 230)
        Mauve     = [Colour]::new(198, 160, 246)
        Red       = [Colour]::new(237, 135, 150)
        Maroon    = [Colour]::new(238, 153, 160)
        Peach     = [Colour]::new(245, 169, 127)
        Yellow    = [Colour]::new(238, 212, 159)
        Green     = [Colour]::new(166, 218, 149)
        Teal      = [Colour]::new(139, 213, 202)
        Sky       = [Colour]::new(145, 215, 227)
        Sapphire  = [Colour]::new(125, 196, 228)
        Blue      = [Colour]::new(138, 173, 244)
        Lavender  = [Colour]::new(183, 189, 248)

        # Greys
        Text      = [Colour]::new(202, 211, 245)
        Subtext1  = [Colour]::new(184, 192, 224)
        Subtext0  = [Colour]::new(165, 173, 203)
        Overlay2  = [Colour]::new(147, 154, 183)
        Overlay1  = [Colour]::new(128, 135, 162)
        Overlay0  = [Colour]::new(110, 115, 141)
        Surface2  = [Colour]::new(91, 96, 120)
        Surface1  = [Colour]::new(73, 77, 100)
        Surface0  = [Colour]::new(54, 58, 79)
        Base      = [Colour]::new(36, 39, 58)
        Mantle    = [Colour]::new(30, 32, 48)
        Crust     = [Colour]::new(24, 25, 38)
    }
    'Mocha'     = [Flavour]@{ 
        <# Mocha Flavoured Catppuccin #>
        # Colours
        Rosewater = [Colour]::new(245, 224, 220)
        Flamingo  = [Colour]::new(242, 205, 205)
        Pink      = [Colour]::new(245, 194, 231)
        Mauve     = [Colour]::new(203, 166, 247)
        Red       = [Colour]::new(243, 139, 168)
        Maroon    = [Colour]::new(235, 160, 172)
        Peach     = [Colour]::new(250, 179, 135)
        Yellow    = [Colour]::new(249, 226, 175)
        Green     = [Colour]::new(166, 227, 161)
        Teal      = [Colour]::new(148, 226, 213)
        Sky       = [Colour]::new(137, 220, 235)
        Sapphire  = [Colour]::new(116, 199, 236)
        Blue      = [Colour]::new(137, 180, 250)
        Lavender  = [Colour]::new(180, 190, 254)

        # Greys
        Text      = [Colour]::new(205, 214, 244)
        Subtext1  = [Colour]::new(186, 194, 222)
        Subtext0  = [Colour]::new(166, 173, 200)
        Overlay2  = [Colour]::new(147, 153, 178)
        Overlay1  = [Colour]::new(127, 132, 156)
        Overlay0  = [Colour]::new(108, 112, 134)
        Surface2  = [Colour]::new(88, 91, 112)
        Surface1  = [Colour]::new(69, 71, 90)
        Surface0  = [Colour]::new(49, 50, 68)
        Base      = [Colour]::new(30, 30, 46)
        Mantle    = [Colour]::new(24, 24, 37)
        Crust     = [Colour]::new(17, 17, 27)
    }
}

Export-ModuleMember -Variable Catppuccin
