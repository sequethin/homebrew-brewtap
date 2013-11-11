require 'formula'

# Warning: This is a customized formula! I'm experimenting with lua and homebrew.
# By using this formula, you become part of my experiment ;)

# NOTE: This formula is best used with --with-luajit.
# Not sure why it's not working right with the lua-5.2.2 install.

class Luarocks < Formula
  homepage 'http://luarocks.org'
  head 'https://github.com/keplerproject/luarocks.git'
  url 'http://luarocks.org/releases/luarocks-2.1.1.tar.gz'
  sha1 '696e4ccb5caa3af478c0fbf562d16ad42bf404d5'

  option 'with-stock-luajit', 'Use LuaJIT from master instead of the stock Lua (or sequethin)'
  option 'with-luajit', 'Use LuaJIT from sequethin instead of the stock Lua, or stock luajit'
  option 'with-lua52', 'Use Lua 5.2 from versions instead of the stock Lua (or sequethin) '

  if build.include? 'with-stock-luajit'
    depends_on 'luajit'
  elsif build.include? 'with-luajit'
    depends_on 'sequethin/brewtap/luajit'
  elsif build.include? 'with-lua52'
    depends_on 'lua52'
  else
    depends_on 'sequethin/brewtap/lua'
  end

  fails_with :llvm do
    cause "Lua itself compiles with llvm, but may fail when other software tries to link."
  end

  def install
    # Install to the Cellar, but direct modules to HOMEBREW_PREFIX
    args = ["--prefix=#{prefix}",
            "--rocks-tree=#{HOMEBREW_PREFIX}",
            "--sysconfdir=#{etc}/luarocks"]

    if build.include? 'with-luajit'
      args << "--with-lua-include=#{HOMEBREW_PREFIX}/include/luajit-2.0"
      args << "--lua-suffix=jit"
    end

    system "./configure", *args
    system "make"
    system "make install"
  end

  def caveats; <<-EOS.undent
    Rocks install to: #{HOMEBREW_PREFIX}/lib/luarocks/rocks

    You may need to run `luarocks install` inside the Homebrew build
    environment for rocks to successfully build. To do this, first run `brew sh`.
    EOS
  end

  def test
    opoo "Luarocks test script installs 'lpeg'"
    system "#{bin}/luarocks", "install", "lpeg"
    system "lua", "-llpeg", "-e", 'print ("Hello World!")'
  end
end

__END__
