{ stdenv, fetchurl, yap, tcsh, perl, patchelf }:

stdenv.mkDerivation rec {
  name = "TPTP-${version}";
  version = "7.0.0";

  src = fetchurl {
    url = [
      "http://www.cs.miami.edu/~tptp/TPTP/Distribution/TPTP-v${version}.tgz"
      "http://www.cs.miami.edu/~tptp/TPTP/Archive/TPTP-v${version}.tgz"
    ];
    sha256 = "13rm76lqlgbv15p8as0dpc74z2dfv5xydkhnd0hm3hhi3mn39dk9";
  };

  buildInputs = [ tcsh yap perl patchelf ];

  installPhase = ''
    sharedir=$out/share/tptp

    mkdir -p $sharedir
    cp -r ./ $sharedir

    export TPTP=$sharedir

    tcsh $sharedir/Scripts/tptp2T_install -default

    substituteInPlace $sharedir/TPTP2X/tptp2X_install --replace /bin/mv mv
    tcsh $sharedir/TPTP2X/tptp2X_install -default

    patchelf --interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $sharedir/Scripts/tptp4X

    mkdir -p $out/bin
    ln -s $sharedir/TPTP2X/tptp2X $out/bin
    ln -s $sharedir/Scripts/tptp2T $out/bin
    ln -s $sharedir/Scripts/tptp4X $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Thousands of problems for theorem provers and tools";
    maintainers = with maintainers; [ raskin gebner ];
    # 6.3 GiB of data. Installation is unpacking and editing a few files.
    # No sense in letting Hydra build it.
    # Also, it is unclear what is covered by "verbatim" - we will edit configs
    hydraPlatforms = [];
    platforms = platforms.all;
    license = licenses.unfreeRedistributable;
  };
}
