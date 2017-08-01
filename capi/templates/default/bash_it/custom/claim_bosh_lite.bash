function claim_bosh_lite() {
  env_dir=$(
    set -e

    function msg {
      echo -e $1
    }

    function realpath {
      echo $(cd $(dirname "$1") && pwd -P)/$(basename "$1")
    }

    function claim_random_environment() {
      pool="bosh-lites"

      git pull --rebase --quiet

      for f in ./${pool}/unclaimed/*; do
        test -f "$f" || continue

        msg "Claiming $( basename $f )..."
        claim_specific_environment $(basename $f)
        return $?
      done

      msg "No unclaimed environment found in $pool"
      return 1
    }

    function claim_specific_environment() {
      env=$1

      file=`find . -name $env`

      if [ "$file" == "" ]; then
        echo $env does not exist
        return 1
      fi

      set +e
      file_unclaimed=`echo $file | grep claim | grep -v unclaim`
      set -e

      if [ $file_unclaimed ]; then
        msg $env could not be claimed
        return 1
      fi

      newfile=`echo ${file} | sed -e 's/unclaimed/claimed/'`

      git mv $file $newfile

      git add "${newfile}"
    }

    function create_env_dir() {
			msg "Writing out .envrc..."
      env_file="$1"
      env_name="$(basename "${env_file}")"

      mkdir -p "${env_name}"

			green='\033[32m'
			nc='\033[0m'

			source "${env_file}"
			env_ssh_key_path="$HOME/workspace/capi-env-pool/${env_name}/bosh.pem"
      cat << EOF > "${env_name}/.envrc"
# NOTE: this file was auto-generated by 'claim_bosh_lite' alias

source "${env_file}"

echo "$BOSH_GW_PRIVATE_KEY_CONTENTS" > "${env_ssh_key_path}"
chmod 0600 "${env_ssh_key_path}"
export BOSH_GW_PRIVATE_KEY="${env_ssh_key_path}"

echo -e "\n##################################\n"
echo -e "${green}Some example commands for BOSH + CF${nc}"

default_cmd='bosh deploy ~/workspace/cf-deployment/cf-deployment.yml -v system_domain=\$BOSH_LITE_DOMAIN -o ~/workspace/capi-ci/cf-deployment-operations/use-latest-stemcell.yml -o ~/workspace/capi-ci/cf-deployment-operations/skip-cert-verify.yml -o ~/workspace/cf-deployment/operations/bosh-lite.yml -o ~/workspace/cf-deployment/operations/bypass-cc-bridge.yml'

echo -e "${green}\n## Deploy CF with defaults ##${nc}"
echo "\${default_cmd}"

latest_capi_cmd="\${default_cmd} -o ~/workspace/capi-ci/cf-deployment-operations/use-latest-capi.yml"
echo -e "${green}\n## Deploy CF with latest CAPI release ##${nc}"
echo "upload-capi-release"
echo "\${latest_capi_cmd}"

echo -e "${green}\n## Target this BOSH Director ##${nc}"
echo "cd '$PWD/${env_name}/' && direnv allow"

echo -e "${green}\n## Target CF API ##${nc}"
echo "cf api https://api.${BOSH_LITE_DOMAIN} --skip-ssl-validation"

echo -e "${green}\n## Login to Credhub ##${nc}"
echo 'credhub login -s "\$CREDHUB_SERVER" -u "\$CREDHUB_USERNAME" -p "\$CREDHUB_PASSWORD" --skip-tls-validation'

echo -e "${green}\n## Retrieve CF admin password ##${nc}"
echo "credhub get --name '/bosh-lite/cf/cf_admin_password' --output-json | jq -r '.value'"

echo -e "${green}\n## Unclaim this environment ##${nc}"
echo "unclaim_bosh_lite ${env_name}"

echo -e "${green}\n## Short circuit CC traffic into local process ##${nc}"
echo "~/workspace/capi-release/src/cloud_controller_ng/scripts/short-circuit-cc"

echo -e "${green}\n## Print this help text ##${nc}"
echo ". .envrc"

echo -e "\n##################################\n"
EOF
      git add "${env_name}"
    }

    function commit_and_push() {
      git ci --quiet --message "manually claim ${env} on ${HOSTNAME} [nostory]" --no-verify
      msg "Pushing reservation to $( basename $PWD )..."
      git push --quiet
    }

    >&2 cd ~/workspace/capi-env-pool
    >&2 claim_random_environment $requested_input
    env_file="$(realpath $newfile)"

    >&2 create_env_dir "${env_file}"
    >&2 commit_and_push

    echo "$PWD/$(basename "${env_file}")"
  )

  if [ "$?" == 0 ]; then
    direnv allow "${env_dir}"
    echo "Changing directory to '${env_dir}'..."
    cd "${env_dir}"
  fi
}

export -f claim_bosh_lite
