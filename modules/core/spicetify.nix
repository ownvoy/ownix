{ inputs, ... }:
{
  imports = [
    inputs.spicetify-nix.nixosModules.spicetify
    ../spicetify.nix
  ];
}
