#!/usr/bin/env bash

if command -v code == 0 &>/dev/null; then
    code --install-extension 13xforever.language-x86-64-assembly
    code --install-extension aaron-bond.better-comments
    code --install-extension akamud.vscode-javascript-snippet-pack
    code --install-extension alefragnani.project-manager
    code --install-extension cnshenj.vscode-task-manager
    code --install-extension codezombiech.gitignore
    code --install-extension cschlosser.doxdocgen
    code --install-extension Dart-Code.dart-code
    code --install-extension Dart-Code.flutter
    code --install-extension donjayamanne.git-extension-pack
    code --install-extension donjayamanne.githistory
    code --install-extension donjayamanne.python-extension-pack
    code --install-extension DotJoshJohnson.xml
    code --install-extension eamodio.gitlens
    code --install-extension foxundermoon.shell-format
    code --install-extension fwcd.kotlin
    code --install-extension GitHub.vscode-pull-request-github
    code --install-extension jeff-hykin.better-cpp-syntax
    code --install-extension jolaleye.horizon-theme-vscode
    code --install-extension lizebang.bash-extension-pack
    code --install-extension mads-hartmann.bash-ide-vscode
    code --install-extension magicstack.MagicPython
    code --install-extension mathiasfrohlich.Kotlin
    code --install-extension ms-dotnettools.csharp
    code --install-extension ms-python.python
    code --install-extension ms-toolsai.jupyter
    code --install-extension ms-vscode.cmake-tools
    code --install-extension ms-vscode.cpptools
    code --install-extension ms-vscode.cpptools-extension-pack
    code --install-extension ms-vscode.cpptools-themes
    code --install-extension ms-vscode.hexeditor
    code --install-extension ms-vscode.Theme-MarkdownKit
    code --install-extension ms-vscode.typescript-javascript-grammar
    code --install-extension ms-vscode.vscode-typescript-next
    code --install-extension ms-vsonline.vsonline
    code --install-extension mutantdino.resourcemonitor
    code --install-extension naco-siren.gradle-language
    code --install-extension PKief.material-icon-theme
    code --install-extension redhat.java
    code --install-extension redhat.vscode-xml
    code --install-extension Remisa.shellman
    code --install-extension richardwillis.vscode-gradle
    code --install-extension rogalmic.bash-debug
    code --install-extension rpinski.shebang-snippets
    code --install-extension sethjones.kotlin-on-vscode
    code --install-extension slevesque.vscode-hexdump
    code --install-extension timonwong.shellcheck
    code --install-extension VisualStudioExptTeam.vscodeintellicode
    code --install-extension vscjava.vscode-java-debug
    code --install-extension vscjava.vscode-java-dependency
    code --install-extension vscjava.vscode-java-pack
    code --install-extension vscjava.vscode-java-test
    code --install-extension vscjava.vscode-maven
    code --install-extension wayou.vscode-icons-mac
    code --install-extension zhuangtongfa.material-theme
    code --install-extension ziyasal.vscode-open-in-github
    code --install-extension esbenp.prettier-vscode
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension christian-kohler.path-intellisense
    code --install-extension ionutvmi.path-autocomplete
    code --install-extension mkxml.vscode-filesize
    code --install-extension yzhang.markdown-all-in-one
else
    # TODO install vscode on diffrent system if not exist
    echo "Vscode not installed"
fi
