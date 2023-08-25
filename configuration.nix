# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, callPackage, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

 #Channel

system.autoUpgrade.channel = "https://channels.nixos.org/nixos-unstable";
system.autoUpgrade.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  programs.nm-applet = {
  enable = true;
  indicator = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";


  #battery saver
  services.tlp.enable = true;

  # Garbage Collection

  nix = {
  gc = {
    automatic = true; 
    dates = "weekly"; 
    options = "--delete-older-than 15d";
  };
};



  # Emacs Overlay


nixpkgs.overlays = [
    (import (builtins.fetchTarball {
        url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
	}))
	(self: super: {
      waybar = super.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    })
	];

  services.greetd = {
    enable = true;
    vt = 7;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

 
 # Enable the GNOME Desktop Environment.
 # services.xserver.displayManager.gdm.enable = true;
 # services.xserver.desktopManager.gnome.enable = true;

  # X11 Setup
  services.xserver = {
  enable = true;
  layout = "us";
  xkbVariant = "";
 # displayManager.sddm = {
    #  enable = true;
   #   };
  };

  # Hyprland Setup
  programs.hyprland = {
  enable = true;
  nvidiaPatches = true;
  xwayland.enable = true;
 };

  # Desktop Portal
  xdg.portal = {
      enable = true;
      extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    isNormalUser = true;
    description = "Alex Cook";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  pkgs.nasm
  pkgs.tlp
  pkgs.cmake
  pkgs.nyxt
  pkgs.sioyek
  pkgs.rofi-wayland
  pkgs.swww
  pkgs.networkmanager_dmenu
  pkgs.dunst
  pkgs.networkmanagerapplet
  pkgs.waybar
  pkgs.kitty
  pkgs.brightnessctl
  pkgs.wl-clipboard
  ];

  fonts.fonts = with pkgs; [
  font-awesome
  iosevka
  nerdfonts
  ];

  #Home Manager
  
  home-manager.users.alex = {

    home.stateVersion = "23.05";

    programs.emacs = {
    	  enable = true;
	  package = with pkgs; ((emacsPackagesFor emacsPgtk).emacsWithPackages (epkgs: [
	  emacsPackages.vterm
	  emacsPackages.modus-themes
	  emacsPackages.vertico
	  emacsPackages.orderless
	  emacsPackages.openwith
	  emacsPackages.org-modern
	  emacsPackages.denote]));
	  extraConfig = ''
        (setq inhibit-startup-message t)
	(scroll-bar-mode -1)       
	(tool-bar-mode -1)       
	(tooltip-mode -1)
	(menu-bar-mode -1)

	(require 'modus-themes)
	(setq modus-themes-common-palette-overrides modus-themes-preset-overrides-faint)
      	(load-theme 'modus-vivendi :no-confirm)

	(vertico-mode)
	(require 'orderless)
	(setq completion-styles '(orderless basic)
      	completion-category-overrides '((file (styles basic partial-completion))))

	(openwith-mode t)
        (setq openwith-associations '(("\=.pdf=\'" "sioyek" (file))))

	(set-face-attribute 'default nil :family "Iosevka")
	(with-eval-after-load 'org (global-org-modern-mode))

	(setq denote-directory (expand-file-name "~/Documents/notes"))
	(add-hook 'dired-mode-hook #'denote-dired-mode)
      '';
    };
  };

 services.emacs = {
    enable = true;
    package = config.home-manager.users.alex.programs.emacs.package;
  };

  # SOME programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
