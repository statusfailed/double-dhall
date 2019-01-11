{ mkDerivation, base, dhall, lens-family, lens-family-core, stdenv
, text
}:
mkDerivation {
  pname = "double-dhall";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base dhall lens-family lens-family-core text
  ];
  license = stdenv.lib.licenses.bsd3;
}
