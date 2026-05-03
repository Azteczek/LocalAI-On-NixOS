{
  description = "LocalAI - Build Offline-Safe";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    localai-src = {
      url = "github:mudler/localai";
      flake = false;
    };
    inference-defaults = {
      url = "https://raw.githubusercontent.com/unslothai/unsloth/main/studio/backend/assets/configs/inference_defaults.json";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, localai-src, inference-defaults }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.buildGoModule {
        pname = "localai";
        version = "custom";
        src = localai-src;

        proxyVendor = true;
        vendorHash = "sha256-MdadwbUc2pwfpC9ScsiIfjGIcAOgcwSm6rt/KNlTIuA=";

        nativeBuildInputs = with pkgs; [ 
          pkg-config cmake gcc protobuf go-protobuf protoc-gen-go protoc-gen-go-grpc
        ];

        env = {
          CGO_ENABLED = "0";
        };

       preBuild = ''
          echo ">>> Generowanie gRPC i naprawa modułów..."
          
          # 1. Znajdujemy folder z proto i przygotowujemy miejsce
          PROTO_SOURCE_DIR=$(find . -name "*.proto" -printf "%h" -quit)
          mkdir -p pkg/grpc/proto
          
          # 2. Generujemy pliki .go bezpośrednio tam, gdzie ich szuka kod
          ${pkgs.protobuf}/bin/protoc \
            -I=$PROTO_SOURCE_DIR \
            --go_out=pkg/grpc/proto --go_opt=paths=source_relative \
            --go-grpc_out=pkg/grpc/proto --go-grpc_opt=paths=source_relative \
            $PROTO_SOURCE_DIR/*.proto

          # 3. KLUCZOWY MOMENT: Wymuszamy na Go użycie lokalnego folderu jako paczki gRPC
          # To naprawia błąd "no required module provides package"
          go mod edit -replace github.com/mudler/LocalAI/pkg/grpc/proto=./pkg/grpc/proto
          
          # 4. Naprawa unsloth i UI
          mkdir -p core/config/gen_inference_defaults
          cp ${inference-defaults} core/config/gen_inference_defaults/inference_defaults.json
          mkdir -p core/http/react-ui/dist
          touch core/http/react-ui/dist/placeholder
          
          # 5. Usuwamy generatory sieciowe
          sed -i '/go:generate/d' core/config/inference_defaults.go || true
          
          echo ">>> Sprawdzam czy pliki pb.go istnieją:"
          ls pkg/grpc/proto/*.go
        '';

	subPackages = [ "cmd/local-ai" ];
        doCheck = false;

        postInstall = ''
          [ -f $out/bin/local-ai ] && mv $out/bin/local-ai $out/bin/localai
        '';
      };
    };
}
