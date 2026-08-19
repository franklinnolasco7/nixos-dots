{ ... }:

{
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = false;
      };

      Preferences = {
        "media.hardware-video-decoding.force-enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "gfx.webrender.all" = true;

        "dom.webgpu.enabled" = true;
        "webgl.force-enabled" = true;
        "webgl.disabled" = false;
        "gfx.canvas.accelerated" = true;

        "media.memory_cache_max_size" = 65536;
        "image.mem.decode_bytes_at_a_time" = 32768;
        "network.http.max-persistent-connections-per-server" = 10;

        "browser.translations.enable" = true;
        "javascript.options.wasm_simd" = true;

        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;
        "privacy.donottrackheader.enabled" = true;
        "dom.battery.enabled" = false;

        "browser.ml.enable" = false;
        "browser.ml.chat.enabled" = false;
        "browser.ml.chat.sidebar" = false;
        "browser.ml.chat.shortcuts" = false;
        "browser.ml.chat.prompts" = false;
        "pdfjs.enableAltText" = false;
        "pdfjs.enableGuessAltText" = false;
        "browser.urlbar.quicksuggest.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;

        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
      };
    };
  };
}
