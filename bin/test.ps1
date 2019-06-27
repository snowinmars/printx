Import-Module '.\printx.psm1' -Force

Printx "Text"

Printx "Text with new line" -n

Printx "Plain text" -p
Printx "Invert text" -i
Printx "Underline text" -u
Printx "Bright text" -b

Printx "Invert Underline Bright text" -i -u -b

Printx "Yellow foreground color text" -fc 'yellow'
Printx "Red background color text" -bc 'red'
Printx "Blue foreground - white background color text" -fc 'blue' -bc 'white'

Printx "Red foreground rgb text" -fr '255,0,0'
Printx "Green background rgb text" -br '0,255,0'
Printx "Black foreground - cyan background color text" -fr '0,0,0' -br '0,255,255'

Printx "Orange foreground - cyan background color text" -fc 'orange' -br '0,255,255'
Printx "Black foreground - navy background color text" -fr '0,0,0' -bc 'navy'

Printx "INVERTED Yellow foreground color text" -fc 'yellow' -i
Printx "UNDERLINE Red background color text" -bc 'red' -u
Printx "INVERTED UNDERLINE Blue foreground - white background color text" -fc 'blue' -bc 'white' -i -u

Printx "INVERTED Red foreground rgb text" -fr '255,0,0' -i
Printx "UNDERLINE Green background rgb text" -br '0,255,0' -u
Printx "INVERTED UNDERLINE Black foreground - cyan background color text" -fr '0,0,0' -br '0,255,255' -i -u

Printx "INVERTED UNDERLINE Orange foreground - cyan background color text" -fc 'orange' -br '0,255,255' -i -u
Printx "INVERTED UNDERLINE Black foreground - navy background color text" -fr '0,0,0' -bc 'navy' -i -u
