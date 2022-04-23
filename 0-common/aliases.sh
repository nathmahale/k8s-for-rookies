alias c="clear"
alias dlgn="docker exec -it 9d9 bash"

alias dsize="docker history --human --format '{{.CreatedBy}}: {{.Size}}' $*"
alias dst="docker stop $*"
alias dr="docker rm $*"
alias dri="docker rmi $*"
alias ds="docker system df"
alias dsv="docker system df -v"
alias di="docker images -a"
alias dp="docker ps -a"
alias de="docker exec -it $*"
alias sts="sudo systemctl status $*"
alias str="sudo systemctl restart $*"
alias stpp="sudo systemctl stop $*"
alias sdr="sudo systemctl daemon-reload"
alias 00='sts etcd'
alias 01='sts kube-apiserver'
alias 02='sts kube-scheduler'
alias 03='sts kube-controller-manager'

alias str0="str etcd"
alias str1="str kube-apiserver"
alias str2="str kube-scheduler"
alias str3="str kube-controller-manager"
