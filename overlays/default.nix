final: prev: {
  graphite-gtk-theme = final.callPackage ../pkgs/graphite-gtk-theme/package.nix { };

  # ananicy-cpp 1.2.0 fails against glibc 2.42 headers: several files use
  # std::int32_t / std::memset / std::strerror without including <cstdint>
  # and <cstring>. Drop the includes in until upstream fixes it.
  ananicy-cpp = prev.ananicy-cpp.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sed -i '1i #include <cstdint>\n#include <cstring>' src/platform/linux/backtrace.cpp
      sed -i '1i #include <cstring>' src/utility/argument_parsing/argument.cpp
      sed -i '1i #include <cstring>' src/platform/linux/singleton_process.cpp
    '';
  });
}
