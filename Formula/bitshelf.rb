class Bitshelf < Formula
  desc "Local Markdown-first storage for reusable bits"
  homepage "https://github.com/bswan0002/bitshelf"
  version "0.1.0"
  license "MIT"

  on_macos do
    depends_on macos: :sequoia
    if Hardware::CPU.arm?
      url "https://github.com/bswan0002/bitshelf/releases/download/v0.1.0/bitshelf-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "d71f7ced4a6052f583f7c0f21924336b7bafd9992b3cea5cbbe2e69bf6f359e4"
    else
      url "https://github.com/bswan0002/bitshelf/releases/download/v0.1.0/bitshelf-v0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "2aae608cd90f7f024f536c2f7a684f0fd2882e10fbf725cb028342f7ac590869"
    end
  end

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/bswan0002/bitshelf/releases/download/v0.1.0/bitshelf-v0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "79a9e2f82ff46fa2d1ebd07b908d68120f3457a80569e8a344889479d7826102"
  end

  def install
    bin.install "bs"
    man1.install "bs.1"
    bash_completion.install "completions/bs.bash" => "bs"
    zsh_completion.install "completions/_bs"
    fish_completion.install "completions/bs.fish"
    pkgshare.install "skills", "docs", "CHANGELOG.md", "runtime-notices"
    pkgshare.install "THIRD_PARTY_NOTICES.txt", "DEPENDENCIES.json", "BUILD-INFO.json"
  end

  test do
    config = testpath/"config.toml"
    body = testpath/"body.txt"
    body.write "exact\r\nbody without final newline"
    system bin/"bs", "--config", config, "init", "--store", testpath/"store"
    system bin/"bs", "--config", config, "add", "notes/brew-test", "--file", body
    assert_equal body.read, Utils.safe_popen_read(bin/"bs", "--config", config, "show", "notes/brew-test", "--body")
    system bin/"bs", "--config", config, "edit", "notes/brew-test", "--title", "Homebrew"
    result = JSON.parse(Utils.safe_popen_read(bin/"bs", "--config", config, "list", "--json"))
    assert_equal true, result.fetch("complete")
    assert_equal "Homebrew", result.fetch("results").first.fetch("title")
    assert_equal "bs 0.1.0", Utils.safe_popen_read(bin/"bs", "--version").strip
    assert_equal "0.1.0", (pkgshare/"skills/bitshelf/VERSION").read.strip
    assert_predicate pkgshare/"THIRD_PARTY_NOTICES.txt", :file?
    assert_predicate pkgshare/"DEPENDENCIES.json", :file?
    assert_predicate pkgshare/"runtime-notices/COPYRIGHT-library.html", :file?
    assert_predicate pkgshare/"BUILD-INFO.json", :file?
    assert_predicate pkgshare/"docs/json.md", :file?
    assert_predicate man1/"bs.1", :file?
    assert_predicate bash_completion/"bs", :file?
    assert_predicate zsh_completion/"_bs", :file?
    assert_predicate fish_completion/"bs.fish", :file?
  end
end
