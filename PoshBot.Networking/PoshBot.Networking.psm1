
function Invoke-Ping {
    <#
    .SYNOPSIS
        Tests a connection to a host
    .EXAMPLE
        !ping (<www.google.com> | --name <www.google.com>) [--count 2] [--ipv6]
    #>
    [PoshBot.BotCommand(
        CommandName = 'ping',
        Permissions = 'test-network'
    )]
    [cmdletbinding()]
    param(
        [parameter(Mandatory, Position = 0)]
        [string]$Name,

        [parameter(Position = 1)]
        [int]$Count = 5,

        [parameter(position = 2)]
        [switch]$IPv6
    )

    if ($PSBoundParameters.ContainsKey('IPv6')) {
        $r = Invoke-Command -ScriptBlock { ping.exe $Name -n $Count -6 -a }
    } else {
        $r = Invoke-Command -ScriptBlock { ping.exe $Name -n $Count -4 -a }
    }

    New-PoshBotCardResponse -Type Normal -Text ($r -Join "`n")
}

function Invoke-Dig {
    <#
    .SYNOPSIS
        Perform DNS resolution on a host
    .EXAMPLE
        !dig (<www.google.com> | --name <www.google.com>) [--type <A>] [--server <8.8.8.8>]
    #>
    [PoshBot.BotCommand(
        CommandName = 'dig',
        Permissions = 'test-network'
    )]
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [string]$Name,

        [ValidateSet('A', 'A_AAAA', 'AAAA', 'NS', 'MX', 'MD', 'MF', 'CNAME', 'SOA', 'MB', 'MG', 'MR', 'NULL', 'WKS', 'PTR',
                     'HINFO', 'MINFO', 'TXT', 'RP', 'AFSDB', 'X25', 'ISDN', 'RT', 'SRV', 'DNAME', 'OPT', 'DS', 'RRSIG',
                     'NSEC', 'DNSKEY', 'DHCID', 'NSEC3', 'NSEC3PARAM', 'ANY', 'ALL')]
        [string]$Type = 'A_AAAA',

        [string]$Server
    )

    if ($PSBoundParameters.ContainsKey('Server')) {
        $r = Resolve-DnsName -Name $Name -Type $Type -Server $Server | Format-Table -Autosize | Out-String
    } else {
        $r = Resolve-DnsName -Name $Name -Type $Type -ErrorAction SilentlyContinue | Format-Table -Autosize | Out-String
    }

    if ($r) {
        New-PoshBotCardResponse -Type Normal -Text $r
    } else {
        New-PoshBotCardResponse -Type Warning -Text "Unable to resolve [$Name] :(" -Title 'Rut row' -ThumbnailUrl 'http://images4.fanpop.com/image/photos/17000000/Scooby-Doo-Where-Are-You-The-Original-Intro-scooby-doo-17020515-500-375.jpg'
    }
}

function Invoke-TestPort {
    <#
    .SYNOPSIS
        Perform port testing on a host
    .EXAMPLE
        !testport (srv.domain.local | --ComputerName src.domain.local) [--Port 443]
    #>
    [PoshBot.BotCommand(
        CommandName = 'testport',
        Permissions = 'test-network'
    )]
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [Alias('Name')]
        [string]$ComputerName,

        [parameter(Mandatory)]
        [string]$Port
    )

    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $r = Test-Connection -TargetName $ComputerName -TCPPort $Port -ErrorAction SilentlyContinue |
                Select-Object @{Name ='ComputerName';Expression={$ComputerName}},@{Name='Port';Expression={$Port}},@{Name='Result';Expression={$_}} |
                Format-Table -Autosize |
                Out-String
    }
    else {
        $r = Test-NetConnection -ComputerName $ComputerName -Port $Port -ErrorAction SilentlyContinue | Format-Table -Autosize | Out-String
    }
    if ($r) {
        New-PoshBotCardResponse -Type Normal -Text $r
    } else {
        New-PoshBotCardResponse -Type Warning -Text "Unable to resolve [$ComputerName] :(" -Title 'Rut row' -ThumbnailUrl 'http://images4.fanpop.com/image/photos/17000000/Scooby-Doo-Where-Are-You-The-Original-Intro-scooby-doo-17020515-500-375.jpg'
    }
}



Export-ModuleMember -Function 'Invoke-Ping', 'Invoke-Dig', 'Invoke-TestPort'
