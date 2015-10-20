# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="jnrowe"

# Plug-ins
plugins=(git textmate osx brew terminalapp)

source $ZSH/oh-my-zsh.sh

# Disable auto correct (e.g. 'zsh: correct 'hg' to 'bg' [nyae]?')
unsetopt correct_all

# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

# Fast git auto completion
# http://stackoverflow.com/questions/9810327/git-tab-autocompletion-is-useless-can-i-turn-it-off-or-optimize-it
__git_files () {
    _wanted files expl 'local files' _files
}

# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# http://stackoverflow.com/questions/12508595/ignore-orig-head-in-zsh-git-autocomplete
zstyle ':completion:*:*' ignored-patterns '*ORIG_HEAD'

# Ensure user-installed binaries take precedence
export PATH=~/bin:~/.gems:/opt/local/bin/gem:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin

export EDITOR='subl -w'

# Directory aliases
hash -d repo=~/Code/Autodesk/
hash -d code=~/Code/Autodesk/

# Make sure ruby gems are always loaded
# c.f http://stackoverflow.com/questions/1330226/in-require-no-such-file-to-load-gemname-loaderror
export RUBYOPT="rubygems"

# Add user-installed ruby gems to the path
# c.f. http://guides.rubygems.org/faqs/#user-install
if which ruby >/dev/null && which gem >/dev/null; then
    PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

#faster history search
#type first letter(s) of command you entered,
#press up and find it at once
# bindkey "\e[A" history-beginning-search-backward
# bindkey "\e[B" history-beginning-search-forward

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true
# cache pip-installed packages to avoid re-downloading
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache

export GEM_PATH="~/.gems"
export GEM_PATH="$GEM_HOME"
export GOPATH=$HOME/Code/go-Workspace


####################################################################################################
#   Aliases                                                                                        #
####################################################################################################
alias zshconfig="e ~/.zshrc"

# Home directory is a git repo, but
#  - I don't want to see this in the shell
#  - I don't want to make accidental commits
# Use `dot` to interact with this repo
# Source: http://www.zsh.org/mla/users/2011/msg00679.html
alias dot='HOME=~ GIT_DIR=$HOME/.dotfiles.git/ git --work-tree=$HOME'

# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
fi

# Sync private data with NAS
alias syncprivate="rsync -av --stats --progress 192.168.178.61::backup/Private/ ~/Private"

# Always highlight grep search term
alias grep='grep --color=auto'

# Pings with 5 packets, not unlimited
alias ping='ping -c 5'

# Disk free, in gigabytes, not bytes
alias df='df -h'

# Calculate total disk usage for a folder
alias du='du -h -c'

alias clr='clear;echo "Currently logged in on $(tty), as $(whoami) in directory $(pwd)."'

alias ghdiff='hub compare `git rev-parse HEAD`..`git rev-parse origin/HEAD`'

alias rmsleep='su Administrator -c "sudo rm /private/var/vm/sleepimage"'

# c.f. https://stackoverflow.com/questions/3231759/how-can-i-visualize-per-character-differences-in-a-unified-diff-file
alias worddiff='git diff --color-words="[^[:space:]]|([[:alnum:]]|UTF_8_GUARD)+"'

hash -d blog=~/Private/Code/larsxschneider.github.com/
hash -d pc=~/Private/Code/

# GRC colorizes nifty unix tools all over the place
if $(grc &>/dev/null)
then
  source `brew --prefix`/etc/grc.bashrc
fi

####################################################################################################
#   Work                                                                                           #
####################################################################################################
hash -d code=~/Code

alias testchrome='/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary --disable-web-security --always-enable-dev-tools --enable-logging --v=1'
alias standup='open -a /Applications/Safari.app https://meet.autodesk.com/hanspeter.johner/WQQR7ZJV; sleep 10; killall Safari'

export P4CONFIG=~/.p4settings
