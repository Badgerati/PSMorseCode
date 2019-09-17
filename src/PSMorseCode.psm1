function Get-PSMorseCodeMap
{
    param(
        [switch]
        $Reverse
    )

    $map = @{
        'A' = '.-'
        'N' = '-.'
        'B' = '-...'
        'O' = '---'
        'C' = '-.-.'
        'P' = '.--.'
        'D' = '-..'
        'Q' = '--.-'
        'E' = '.'
        'R' = '.-.'
        'F' = '..-.'
        'S' = '...'
        'G' = '--.'
        'T' = '-'
        'H' = '....'
        'U' = '..-'
        'I' = '..'
        'V' = '...-'
        'J' = '.---'
        'W' = '.--'
        'K' = '-.-'
        'X' = '-..-'
        'L' = '.-..'
        'Y' = '-.--'
        'M' = '--'
        'Z' = '--..'
        '1' = '.----'
        '2' = '..---'
        '3' = '...--'
        '4' = '....-'
        '5' = '.....'
        '6' = '-....'
        '7' = '--...'
        '8' = '---..'
        '9' = '----.'
        '0' = '-----'
        ',' = '--..--'
        '.' = '.-.-.-'
        '?' = '..--..'
        ';' = '-.-.-.'
        ':' = '---...'
        '/' = '-..-.'
        '-' = '-....-'
        "'" = '.----.'
        '"' = '.-..-.'
        '_' = '..--.-'
        '(' = '-.--.'
        ')' = '-.--.-'
        '@' = '.--.-.'
        ' ' = '     '
    }

    if ($Reverse) {
        $newMap = @{}

        $map.Keys | ForEach-Object {
            $newMap[$map[$_]] = $_
        }

        $map = $newMap
    }

    return $map
}

function Get-PSMorseCodeAtomMap
{
    return @{
        '.' = '10'
        '-' = '1110'
        ' ' = '00000'
    }
}

function Get-PSMorseCodeDurationMap
{
    return @{
        ' ' = 100
        '.' = 100
        '-' = 300
    }
}

function ConvertTo-MorseCode
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]
        $InputObject,

        [switch]
        $AsBinary
    )

    if ([string]::IsNullOrWhiteSpace($InputObject)) {
        return [string]::Empty
    }

    $InputObject = ($InputObject -replace '\s+', ' ')
    $map = Get-PSMorseCodeMap

    $value = (($InputObject -split ' ') | ForEach-Object {
        (($_.ToCharArray() | ForEach-Object {
            $morse = $map[[string]$_]
            if (![string]::IsNullOrEmpty($morse)) {
                $morse
            }
        }) -join '   ')
    }) -join '       '

    if ($AsBinary) {
        $value = ($value -replace '       ', '000000')
        $value = ($value -replace '   ', '00')
        $value = ($value -replace '\.', '10')
        $value = ($value -replace '-', '1110')
    }

    return $value
}

function ConvertFrom-MorseCode
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]
        $InputObject
    )

    if ([string]::IsNullOrWhiteSpace($InputObject)) {
        return [string]::Empty
    }

    $map = (Get-PSMorseCodeMap -Reverse)

    return (($InputObject -split '       ') | ForEach-Object {
        (($_ -split '   ') | ForEach-Object {
            $map[($_ -replace '\s+', '')]
        }) -join ''
    }) -join ' '
}

function Read-MorseCode
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]
        $InputObject
    )

    $sleep = $false
    $map = Get-PSMorseCodeDurationMap

    $InputObject.ToCharArray() | ForEach-Object {
        $char = [string]$_

        if ($char -eq ' ') {
            $sleep = $false
            Start-Sleep -Milliseconds ($map[$char])
        }
        else {
            if ($sleep) {
                Start-Sleep -Milliseconds ($map[' '])
            }

            $sleep = $true
            [System.Console]::Beep(1000, $map[$char])
        }
    }
}