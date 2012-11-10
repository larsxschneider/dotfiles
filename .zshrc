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

# Paths
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:~/bin
export EDITOR='subl -w'

# Directory aliases
hash -d repo=~/Code/
hash -d code=~/Code/

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

# GRC colorizes nifty unix tools all over the place
if $(grc &>/dev/null)
then
  source `brew --prefix`/etc/grc.bashrc
fi

####################################################################################################
#   Work                                                                                           #
####################################################################################################
export EMSCRIPTEN_ROOT=~/Code/AIM360Viewer/3rdParty/External/Emscripten/

hash -d aim=~/Code/AIM360Viewer
hash -d ff=~/Code/AIM360Viewer/3rdParty/Autodesk/Firefly/
hash -d ems=~/Code/AIM360Viewer/3rdParty/External/Emscripten/

alias buildlog='ssh build "tail -f ~/AIM360Viewer/githook-server.log -n 100"'
alias testchrome='/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary --disable-web-security --always-enable-dev-tools'
