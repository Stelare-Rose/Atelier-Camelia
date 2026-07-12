{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
	};

	outputs = { self, nixpkgs, quickshell }@inputs:
	let
		system = "x86_64-linux";
		
		pkgs = import inputs.nixpkgs{
			inherit system;
			config.allowUnfree = true;
		};
	in 
	{
		devShells.${system}.default = pkgs.mkShell rec {
			name="Camelia";
			packages = with pkgs; [
          quickshell.packages.${system}.default 
          qt6.qtdeclarative                 
          qt6.qt5compat                          
          qt6.qtsvg                          
          qt6.qtwayland                         
				];
			shellHook = "tmux -L Camelia new-session -A -s Camelia";
			};
		};
	}
