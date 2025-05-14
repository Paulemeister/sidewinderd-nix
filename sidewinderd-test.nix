{
  pkgs,
  self,
  ...
}:
pkgs.nixosTest {
  name = "sidewinderdTest";
  nodes.machine = {
    config,
    pkgs,
    ...
  }: {
    imports = [./module.nix];
    services.sidewinderd = {
      enable = true;
    };
    system.stateVersion = "23.11";
  };

  testScript = ''
    print(machine.execute("cat /etc/sidewinderd.conf",False)[1])
    machine.wait_for_unit("sidewinderd.service")
  '';
}
