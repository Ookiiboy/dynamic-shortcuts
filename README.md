# Dynamic Shortcuts

## Forward
The initial idea, and much of the initial work of this tool is based on work from NixOS community member [Krutonium](https://github.com/Krutonium), without whom it would not exsist.

## So what is this thing?
From a high-level, this is a wrapper around `nix run`. If you don't know, `nix run` enables an individual to run arbitrary packages without needing to add them to a particular configuration. It's dynamic, and after garbage is collected, the package is removed. This is quite useful for demoing, or running software intermitently. This creates `.desktop` shortcuts for those commands.

## Who can use it?
People who aren't chuds*, and use `home-manager` for their linux desktop.

## How do I use it?
### Inputs
Add this to your flake inputs.
```nix
inputs.dynamic-shortcuts.url = "github:Ookiiboy/dynamic-shortcuts";
```
### Outputs
Add the input to the output. Then add the module to your home-manager user.
```nix
outputs = {
    dynamic-shortcuts,
    # Other stuff.
  } : {
    # I don't know how you have your NixOS/Home Manager config setup, but it
    # should be something along the lines of...
    home-manager.users."COOL USER NAME".imports = [
        dynamic-shortcuts.modules.home-manager
        {
          services.dynamic-shortcuts = {
            enable = true;
            shortcuts = with pkgs; [
              # The packages you want to shortcut.
            ];
          };
        }
      ]
  }
```
### Cavets
Ideally the packages you specify should be desktop applications, and singular in execution. That is, something that installs many desktop applications might not work as expected. PR's to fix this are welcome.

## TO(maybe)DO
- NixOS module
- Darwin support (How do we do the equvilent on MacOS desktop?)
