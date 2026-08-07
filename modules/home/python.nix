{ pkgs, ... }:
{
  # Python environment for data collection / scraping work (deepfake dataset).
  home.packages = [
    (pkgs.python3.withPackages (
      ps: with ps; [
        requests
        beautifulsoup4
        opencv4
        numpy
      ]
    ))
  ];
}
