require_relative "../lib/version.rb"

Releasy::Project.new do
  name "Throckmorton"
  version Game::VERSION
  executable "bin/throckmorton"
  files `git ls-files`.split("\n")
  files.exclude ".gitignore", "Rakefile"
  exposed_files %w[README.md]
  #add_link "http://spooner.github.com/games/throckmorton", "Throckmorton website"
  exclude_encoding

  add_build :osx_app do
    url "com.github.spooner.games.throckmorton"
    wrapper "../releasy/wrappers/gosu-mac-wrapper-0.7.41.tar.gz"
    add_package :tar_gz
  end

  add_build :source do
    add_package :zip
  end

  add_build :windows_folder do
    #icon "media/icon.ico"
    ocra_parameters "--no-enc"
    add_package :zip
  end

  add_build :windows_installer do
    #icon "media/icon.ico"
    readme "README.md"
    start_menu_group "Spooner Games"
    add_package :zip
  end

  add_deploy :github

  add_deploy :local do
    path "C:/Users/Spooner/Dropbox/Public/games/throckmorton"
  end
end