{ lib, buildGoModule, fetchFromGitHub, buildNpmPackage, nodejs_22 }:

let
  pname = "paperless-gpt";
  version = "0.25.1";

  src = fetchFromGitHub {
    owner = "icereed";
    repo = "paperless-gpt";
    rev = "v${version}";
    hash = "sha256-bkBbvdDCFV2VeC42lArhZipklFD8DHmSqCARSlYl72Q=";
  };

  web-app = buildNpmPackage {
    pname = "${pname}-frontend";
    inherit version src;
    sourceRoot = "${src.name}/web-app";
    npmDepsHash = "sha256-7PxH8kS28x8Sv5tD+Kohdv1CakKh8gIA9e9LGcWA960=";

    nodejs = nodejs_22;

    patches = [
      ./vite-configurable-proxy.patch
    ];

    installPhase = ''
      cp -r dist $out
    '';
  };
in
buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-ZqJA9V4x4B7tAeIYbgSkFzj9ejhy6hfpEfAL90CQckw=";

  doCheck = false;

  preBuild = ''
    mkdir -p web-app/dist
    cp -r ${web-app}/* web-app/dist/
  '';

  meta = with lib; {
    description = "Use LLMs and LLM Vision (OCR) to handle paperless-ngx";
    homepage = "https://github.com/icereed/paperless-gpt";
    license = licenses.mit;
    mainProgram = "paperless-gpt";
  };
}
