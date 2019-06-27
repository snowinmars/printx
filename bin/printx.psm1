# Usage: Printx ['text'] [options]
#   Import-Module '.\printx.psm1' -Force
#   Printx "test" -u -i
#   Printx "test" -c 'yellow' | Write-Information -InformationAction Continue
#   $str = Printx "test" -r '255,0,0'
# Beware: a terminal in an IDE could override colors
#
# Summary: A better Write-Host that lets you print text in full RGB colors.
# Help: Print RGB text or plain text with printx.
#
# List of ANSI codes: https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
#
# Options:
#   -c, -color   [color]         Print text in one of the 19 colors specified below.
#   -r, -rgb     ['r,g,b']       Print text with an RGB color.
#
#   -i, -invert                  Swap background and foreground colors.
#   -p, -plain                   Print plain, redirectable text.
#   -u, -underline               Print underlined text.
#   -b, -bold                    Print bold text (on supported consoles)
#   -n, -newline                 Print a newline after the text
#
#   -h, -help                    Print this help message.
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

Function usage($text) {
    $text | Select-String '(?m)^# Usage: ([^\n]*)$' | ForEach-Object { "Usage: " + $_.matches[0].groups[1].value }
}

Function summary($text) {
    $text | Select-String '(?m)^# Summary: ([^\n]*)$' | ForEach-Object { $_.matches[0].groups[1].value }
}

Function help_msg($text) {
    $help_lines = $text | Select-String '(?ms)^# Help:(.(?!^[^#]))*' | ForEach-Object { $_.matches[0].value; }
    $help_lines -replace '(?ms)^#\s?(Help: )?', ''
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
    [CmdletBinding()]
    param (
        [parameter(valuefrompipeline=$true)]
        $text,
        [alias('c')]
        $foregroundColor,
        [alias('r')]
        $rgb,
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
    $ESC = [char]27

    if ($help) {
        try {
            $text = (Get-Content $MyInvocation.PSCommandPath -raw)
        } catch {
            $text = (Get-Content $PSCOMMANDPATH -raw)
        }
        $helmp = usage $text
        $helmp += "`n"
        $helmp += summary $text
        $helmp += "`n"
        $helmp += help_msg $text
        $helmp | & $meow

        return;
    }

    $arg = if ($newline) { "`n" }

    if (-not $plain) {
        $plain = (-not $invert) -and (-not $bold) -and (-not $underline) -and (-not $foregroundColor) -and (-not $rgb)
    }

    if ($plain) {
        $output = "$text$arg"
    }
    else {
        $output = "$ESC[0m" # start with no modifiers

        if ($invert) { $output += "$ESC[7m" }
        if ($bold) { $output += "$ESC[1m" }
        if ($underline) { $output += "$ESC[4m" }
        $output += "$ESC[?25l" # no cursor

        if ($foregroundColor) {
            if ($colors.Contains($foregroundColor)) {
                $r = ($colors.$foregroundColor)[0]
                $g = ($colors.$foregroundColor)[1]
                $b = ($colors.$foregroundColor)[2]
                $output += "$ESC[38;2;${r};${g};${b}m$text$ESC[39m$arg"
            } else {
                Write-Error "printx: error: color $color is not valid. Use an RGB value instead"
                break
            }
        }
        elseif ($rgb) {
            if (($rgb.Split(',')).Count -lt 3) {
                Write-Error "printx: error: The provided RGB value is not valid or does not have the correct delimiter"
                break
            }
            $r = (([Int]::Parse((($rgb.Split(','))[0]))) % 256)
            $g = (([Int]::Parse((($rgb.Split(','))[1]))) % 256)
            $b = (([Int]::Parse((($rgb.Split(','))[2]))) % 256)
            $output += "$ESC[38;2;${r};${g};${b}m$text$ESC[39m$arg"
        } else {
            $output += $text
        }

        $output += "$ESC[?25h" # allow cursor
        if ($underline) { $output += "$ESC[24m" }
        if ($bold) { $output += "$ESC[1m" }
        if ($invert) { $output += "$ESC[27m" }

        $output += "$ESC[0m" # continue with no modifiers
    }

    Write-Output $output
}

Export-ModuleMember -Function 'Printx'