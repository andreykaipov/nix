self: super: {
  dircolors_hex = import ../cli/dircolors.hex;
  dns-tcp-socks-proxy = import ../cli/dns-tcp-socks-proxy;
  extempore = import ../cli/extempore;
  iproute2mac = import ../cli/iproute2mac;
  win32yank = import ../cli/win32yank;
  wudo = import ../cli/wsl-sudo;

  fly-v4_2_5 = import ../cli/fly-v4.2.5;
  fly-v5_7_2 = import ../cli/fly-v5.7.2;
  safe-v0_9_9 = import ../cli/safe-v0.9.9;
  spruce-v1_18_2 = import ../cli/spruce-v1.18.2;
  bosh-v5_2_2 = import ../cli/bosh-v5.2.2;
}
