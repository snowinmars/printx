# Usage: Printx ['text'] [options]
#   Import-Module '.\printx.psm1' -Force
#   Printx "test" -u -i
#   Printx "test" -c 'yellow' | Write-Information -InformationAction Continue
#   $str = Printx "test" -r '255,0,0'
# Beware: a terminal in an IDE could override colors
#
# List of ANSI codes: https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
#
# Colors:
#   normal        rgb(150,150,150)
#   black         rgb(000,000,000)
#   white         rgb(255,255,255)
#   silver        rgb(192,192,192)
#   gray          rgb(128,128,128)
#   yellow        rgb(255,255,000)
#   gold          rgb(255,215,000)
#   orange        rgb(255,165,000)
#   red           rgb(255,000,000)
#   cyan          rgb(000,255,255)
#   teal          rgb(000,128,128)
#   blue          rgb(000,000,255)
#   navy          rgb(000,000,128)
#   magenta       rgb(255,000,255)
#   purple        rgb(128,000,128)
#   maroon        rgb(128,000,000)
#   green         rgb(000,128,000)
#   lime          rgb(000,255,000)
#   olive         rgb(128,128,000)

############################################################

Function Format-Tag {
    param (
        $raw
    )

    Write-Output "$ESC[${raw}m"
}

Function Get-ForegroundOpenTag {
    param (
        $r,
        $g,
        $b
    )

    $str = Get-ForegroundOpen $r $g $b
    Format-Tag $str
}

Function Get-BackgroundOpenTag {
    param (
        $r,
        $g,
        $b
    )

    $str = Get-BackgroundOpen $r $g $b
    Format-Tag $str
}

Function Get-ForegroundOpen {
    param (
        $r,
        $g,
        $b
    )

    Write-Output "38;2;${r};${g};${b}"
}

Function Get-BackgroundOpen {
    param (
        $r,
        $g,
        $b
    )

    Write-Output "48;2;${r};${g};${b}"
}

Function Get-ForegroundCloseTag {
    Format-Tag "39"
}

Function Get-BackgroundCloseTag {
    Format-Tag "49"
}

Function Format-Output {
    param (
        $openTag,
        $text,
        $closeTag,
        $arg
    )

    Write-Output "$openTag$text$closeTag$arg"
}

Function Get-ColorsFromColorName {
    param (
        $colorName
    )

    if (-not ($colors.Contains($colorName))) {
        Write-Error "printx: error: color $colorName is not valid"
        break
    }

    if ($colors.Contains($colorName)) {
        Write-Output @(($colors.$colorName)[0],
                       ($colors.$colorName)[1],
                       ($colors.$colorName)[2])
    } else {
        Write-Error "printx: error: color $colorName is not valid"
        break
    }
}

Function Get-ColorsFromArray {
    param (
        [parameter(ValueFromPipeline=$true)]
        $array
    )

    if (($array.Split(',')).Count -lt 3) {
        Write-Error "printx: error: The provided RGB value is not valid or does not have the correct delimiter"
        break
    }

    Write-Output @((([Int]::Parse((($array.Split(','))[0]))) % 256),
                   (([Int]::Parse((($array.Split(','))[1]))) % 256),
                   (([Int]::Parse((($array.Split(','))[2]))) % 256))
}

############################################################

# The color definitions
[hashtable]$colors = @{
    normal  =   @(150, 150, 150);
    black   =   @(000, 000, 000);
    white   =   @(255, 255, 255);
    silver  =   @(192, 192, 192);
    gray    =   @(128, 128, 128);
    yellow  =   @(255, 255, 000);
    gold    =   @(255, 215, 000);
    orange  =   @(255, 165, 000);
    red     =   @(255, 000, 000);
    cyan    =   @(000, 255, 255);
    teal    =   @(000, 128, 128);
    blue    =   @(000, 000, 255);
    navy    =   @(000, 000, 128);
    magenta =   @(255, 000, 255);
    purple  =   @(128, 000, 128);
    maroon  =   @(128, 000, 000);
    green   =   @(000, 128, 000);
    lime    =   @(000, 255, 000);
    olive   =   @(128, 128, 000);
}

Function Printx {
    <#
        .SYNOPSIS
            Write decorated colorfull text to the output pipe

        .EXAMPLE
            # In this example the 'invert' and 'underline' filters applied to the "test" string
            Import-Module '.\printx.psm1' -Force
            Printx "test" -u -i

        .EXAMPLE
            # In this example the 'foreground color' filter applied to the "test" string
            Import-Module '.\printx.psm1' -Force
            Printx "test" -fc 'yellow' | Write-Information -InformationAction Continue

        .EXAMPLE
            # In this example the 'backgound rbg' and 'foreground color' filters applies to the "test" string
            Import-Module '.\printx.psm1' -Force
            $str = Printx "test" -br '255,0,0' -fc 'blue'

        .PARAMETER text
            Alias: N/A
            Data Type: String
            Mandatory: True
            Description: The input text
            Example(s): 'test'
            Default Value: N/A
            Notes: N/A

        .PARAMETER foregroundColor
            Alias: fc
            Data Type: String
            Mandatory: False
            Description: The one of the standart colors. Can't be provided along with 'foregroundRgb' parameter
            Example(s): 'yellow'
            Default Value: N/A
            Notes: See colors list: https://blogs.technet.microsoft.com/gary/2013/11/20/sample-all-powershell-console-colors/

        .PARAMETER backgroundColor
            Alias: bc
            Data Type: String
            Mandatory: False
            Description: The one of the standart colors. Can't be provided along with 'backgroundRgb' parameter
            Example(s): 'yellow'
            Default Value: N/A
            Notes: See colors list: https://blogs.technet.microsoft.com/gary/2013/11/20/sample-all-powershell-console-colors/

        .PARAMETER foregroundRgb
            Alias: fr
            Data Type: String
            Mandatory: False
            Description: String with rgb values, separated by comma. Can't be provided along with 'foregroundColor' parameter
            Example(s): '255,0,0'
            Default Value: N/A
            Notes: See colors list: https://blogs.technet.microsoft.com/gary/2013/11/20/sample-all-powershell-console-colors/

        .PARAMETER backgroundRgb
            Alias: br
            Data Type: String
            Mandatory: False
            Description: String with rgb values, separated by comma. Can't be provided along with 'backgroundColor' parameter
            Example(s): '255,0,0'
            Default Value: N/A
            Notes: See colors list: https://blogs.technet.microsoft.com/gary/2013/11/20/sample-all-powershell-console-colors/

        .PARAMETER plain
            Alias: p
            Data Type: switch
            Mandatory: False
            Description: Write text as plain
            Example(s): N/A
            Default Value: N/A
            Notes: N/A

        .PARAMETER invert
            Alias: i
            Data Type: switch
            Mandatory: False
            Description: Write text as inverted (switch foreground to background)
            Example(s): N/A
            Default Value: N/A
            Notes: N/A

        .PARAMETER bold
            Alias: b
            Data Type: switch
            Mandatory: False
            Description: Write text as bold/bright
            Example(s): N/A
            Default Value: N/A
            Notes: N/A

        .PARAMETER underline
            Alias: u
            Data Type: switch
            Mandatory: False
            Description: Write text as underlined
            Example(s): N/A
            Default Value: N/A
            Notes: N/A

        .PARAMETER newline
            Alias: n
            Data Type: switch
            Mandatory: False
            Description: Place new line after text
            Example(s): N/A
            Default Value: N/A
            Notes: N/A

        .PARAMETER help
            Alias: h
            Data Type: switch
            Mandatory: False
            Description: Show help
            Example(s): N/A
            Default Value: N/A
            Notes: N/A
    #>

    [CmdletBinding()]
    param (
        [parameter(valuefrompipeline=$true)]
        [string]$text,
        [alias('fc')]
        $foregroundColor,
        [alias('bc')]
        $backgroundColor,
        [alias('fr')]
        $foregroundRgb,
        [alias('br')]
        $backgroundRgb,
        [alias('p')]
        [switch]$plain,
        [alias('i')]
        [switch]$invert,
        [alias('b')]
        [switch]$bold,
        [alias('u')]
        [switch]$underline,
        [alias('n')]
        [switch]$newline,
        [alias('h')]
        [switch]$help
    )

    $meow = "$psscriptroot\..\lib\bin\meow.ps1"

    # The ascii escape character
    $isDebug = $DebugPreference -ne "SilentlyContinue"

    if ($isDebug) {
        $ESC = "(char)27"
    } else {
        $ESC = [char]27
    }

    if ($help) {
        Get-Help -Name Printx -Full

        return;
    }

    $arg = if ($newline) { "`n" }


    if (-not $plain) {
        $plain = (-not $invert) -and `
                 (-not $bold) -and `
                 (-not $underline) -and `
                 (-not $foregroundColor) -and `
                 (-not $backgroundColor) -and `
                 (-not $foregroundRgb) -and `
                 (-not $backgroundRgb)
    }

    if ($plain) {
        if (-not $text) {
            Get-Help -Name Printx -Full
            return;
        }

        Format-Output "" $text "" $arg
        return
    }


    if (($foregroundColor -and $foregroundRgb) `
        -or `
        ($backgroundColor -and $backgroundRgb)) {
        Write-Error "You can't specify several colors for one slot"
        return;
    }


    if ($foregroundColor) {
        $foregroundArray = Get-ColorsFromColorName $foregroundColor
    }

    if ($foregroundRgb) {
        $foregroundArray = $foregroundRgb | Get-ColorsFromArray
    }

    if ($backgroundColor) {
        $backgroundArray = Get-ColorsFromColorName $backgroundColor
    }

    if ($backgroundRgb) {
        $backgroundArray = $backgroundRgb | Get-ColorsFromArray
    }


    $output = "$ESC[0m" # start with no modifiers

    if ($invert) { $output += "$ESC[7m" }
    if ($bold) { $output += "$ESC[1m" }
    if ($underline) { $output += "$ESC[4m" }
    $output += "$ESC[?25l" # no cursor

    if ($foregroundArray -and $backgroundArray) {
        Write-Debug "foregroundArray and backgroundArray $foregroundArray $backgroundArray"

        $fOpen = Get-ForegroundOpen $foregroundArray[0] $foregroundArray[1] $foregroundArray[2]
        $fClose = Get-ForegroundCloseTag
        $bOpen = Get-BackgroundOpen $backgroundArray[0] $backgroundArray[1] $backgroundArray[2]
        $bClose = Get-BackgroundCloseTag

        $open = Format-Tag "${fOpen};${bOpen}"
        $close = "$bClose$fClose"

        $output += Format-Output $open $text $close $arg
    } elseif ($foregroundArray) {
        Write-Debug "foregroundArray $foregroundArray"
        $open = Get-ForegroundOpenTag $foregroundArray[0] $foregroundArray[1] $foregroundArray[2]
        $close = Get-ForegroundCloseTag

        $output += Format-Output $open $text $close $arg
    } elseif ($backgroundArray) {
        Write-Debug "backgroundArray $backgroundArray"
        $open = Get-BackgroundOpenTag $backgroundArray[0] $backgroundArray[1] $backgroundArray[2]
        $close = Get-BackgroundCloseTag

        $output += Format-Output $open $text $close $arg
    } else {
        Write-Debug "plain"
        $output += $text
    }

    $output += "$ESC[?25h" # allow cursor
    if ($underline) { $output += "$ESC[24m" }
    if ($bold) { $output += "$ESC[1m" }
    if ($invert) { $output += "$ESC[27m" }

    $output += "$ESC[0m" # continue with no modifiers

    Write-Output $output
}

Export-ModuleMember -Function 'Printx'