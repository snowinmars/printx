# Usage: printx ['text'] [options]
# Summary: A better Write-Host that lets you print text in full RGB colors.
# Help: Print RGB text or plain text with printx.
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
# Note: if you do not want any color, the -p option MUST be specified.
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

Function Printx {
    [CmdletBinding()]
    param (
        [parameter(valuefrompipeline=$true)]
        $text,
        [alias('c')]
        $color,
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

    # The ascii escape character
    $E = [char]27

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
    }

    $arg = if ($newline) { "`n" }

    if (!$plain) {
        if ($invert) { write-host "$E[7m" -nonewline }
        if ($bold) { write-host "$E[1m" -nonewline }
        if ($underline) { write-host "$E[4m" -nonewline }
        write-host "$E[?25l" -nonewline

        if ($color) {
            if ($colors.Contains($color)) {
                $r = ($colors.$color)[0]
                $g = ($colors.$color)[1]
                $b = ($colors.$color)[2]
                write-host "$E[38;2;${r};${g};${b}m$text$E[38;2;150;150;150m$arg" -nonewline
            } else {
                "printx: $E[38;2;255;0;0merror: color $color is not valid. Use an RGB value instead.$E[38;2;150;150;150m"
                break
            }
        }
        elseif ($rgb) {
            if (($rgb.Split(',')).Count -lt 3) {
                "printx: $E[38;2;255;0;0merror: The provided RGB value is not valid or does not have the correct delimiter.$E[38;2;150;150;150m"
                break
            }
            $r = (([Int]::Parse((($rgb.Split(','))[0]))) % 256)
            $g = (([Int]::Parse((($rgb.Split(','))[1]))) % 256)
            $b = (([Int]::Parse((($rgb.Split(','))[2]))) % 256)
            write-host "$E[38;2;${r};${g};${b}m$text$E[38;2;150;150;150m$arg" -nonewline
        }

        write-host "$E[?25h" -nonewline
        if ($invert) { write-host "$E[27m" -nonewline }
        if ($bold) { write-host "$E[1m" -nonewline }
        if ($underline) { write-host "$E[24m" -nonewline }
    }
    else {
        write-host "$text$arg" -nonewline
    }
}

Export-ModuleMember -Function 'Printx'