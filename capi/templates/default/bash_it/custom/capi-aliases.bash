alias resprout='(cd ~/workspace/sprout-capi && git pull && chruby-exec system -- bundle exec soloist)'

# CATs
alias cats='(cd ~/workspace/cf-release/src/github.com/cloudfoundry/cf-acceptance-tests && CONFIG=$PWD/integration_config.json bin/test --nodes=3)'

# Deploying (bosh1 + cf-release)
alias qnd_deploy='(cd ~/workspace/cf-release && scripts/deploy-dev-release-to-bosh-lite --no-manifest)'
alias qnd_deploy_diego='(cd ~/workspace/diego-release && bosh --parallel 10 sync blobs && scripts/update && scripts/deploy && bosh deployment ~/workspace/cf-release/bosh-lite/deployments/cf.yml)'
alias qnd_deploy_manifest='(cd ~/workspace/cf-release && scripts/deploy-dev-release-to-bosh-lite)'

# Deploying (bosh2 + cf-deployment)
alias upload_capi_release='~/workspace/capi-release/scripts/create-and-upload'
alias create_and_deploy='upload_capi_release && ~/workspace/capi-release/scripts/deploy'
alias create_and_force_deploy='upload_capi_release && ~/workspace/capi-release/scripts/deploy -n'
alias bootstrap_cf='~/workspace/capi-release/scripts/bootstrap-cf'

# PSQL
alias psql_bosh_lite='~/workspace/capi-release/scripts/psql-bosh-lite'

#FASD
alias v='fasd -e vim'

alias b='bundle exec'
alias bake='bundle exec rake'

# Git aliases
alias gd='git diff'
alias gdc='git diff --cached'
alias g='git status'

# Misc aliases
alias gi='gem install'
