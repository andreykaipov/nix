# Lets our WSL VM access servers on our Windows host
#
# https://github.com/Microsoft/WSL/issues/1032#issuecomment-792892600

function main {
    $name = 'WSL Inbound'
    $netalias = 'vEthernet (WSL)'
    $rule = Get-NetFirewallRule -Name $name 2> $null

    if ($rule) {
        Write-Output 'Inbound WSL firewall rule already exists!'
    } else {
        Write-Output 'Creating inbound WSL firewall rule...'
        New-NetFirewallRule `
            -DisplayName $name `
            -Name $name `
            -Direction Inbound `
            -InterfaceAlias $netalias `
            -Action Allow
    }

    Write-Output 'Done'
}

main
