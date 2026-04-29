{ host, ... }:
let
  vars = import ../../hosts/${host}/variables.nix;
  printEnable = vars.printEnable;
  printerName = vars.printerName or null;
  printerLocation = vars.printerLocation or null;
  printerDescription = vars.printerDescription or null;
  printerUri = vars.printerUri or null;
  printerModel = vars.printerModel or null;
  printerPPDOptions = vars.printerPPDOptions or { };
in
{
  services = {
    printing = {
      enable = printEnable;
      drivers = [
        # pkgs.hplipWithPlugin
      ];
    };
    avahi = {
      enable = printEnable;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = printEnable;
  };

  hardware.printers = {
    ensurePrinters =
      if printEnable && printerName != null && printerUri != null && printerModel != null then
        [
          {
            name = printerName;
            location = printerLocation;
            description = printerDescription;
            deviceUri = printerUri;
            model = printerModel;
            ppdOptions = printerPPDOptions;
          }
        ]
      else
        [ ];

    ensureDefaultPrinter =
      if printEnable && printerName != null && printerUri != null && printerModel != null then
        printerName
      else
        null;
  };
}
