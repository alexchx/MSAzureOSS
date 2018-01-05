#!/bin/bash

function print_usage() {
  cat <<EOF
Command
  $0
Arguments
  --subscription|-su               [Required]: Azure subscription id
  --tenant|-t                      [Required]: Azure tenant id
  --appid|-aid                     [Required]: Azure service principal client id
  --secret|-s                      [Required]: Azure service principal secret
  --resourcegroup|-rg              [Required]: Azure resource group for the components
  --location|-l                    [Required]: Azure resource group location for the components
  --imageResourcegroup|-irg        [Required]: Azure resource group for the VM image
  --image|-i                                 : VM image name
  --repository|-rr                 [Required]: Repository targeted by the build
  --artifacts_location|-al                   : Url used to reference other scripts/artifacts.
  --sas_token|-st                            : A sas token needed if the artifacts location is private.
  --custom_artifacts_location|-cal           : Url used to reference custom scripts/artifacts.
  --custom_sas_token|-cst                    : A sas token needed if the custom artifacts location is private.
EOF
}

function throw_if_empty() {
  local name="$1"
  local value="$2"
  if [ -z "$value" ]; then
    >&2 echo "Parameter '$name' cannot be empty."
    print_usage
    exit -1
  fi
}

function run_util_script() {
  local script_path="$1"
  shift
  curl --silent "${artifacts_location}${script_path}${artifacts_location_sas_token}" | sudo bash -s -- "$@"
  local return_value=$?
  if [ $return_value -ne 0 ]; then
    >&2 echo "Failed while executing script '$script_path'."
    exit $return_value
  fi
}

#set defaults
jenkins_url="http://localhost:8080/"
jenkins_username="admin"
jenkins_password=""
image="myPackerLinuxImage"
job_short_name="Build VM"
artifacts_location="https://raw.githubusercontent.com/Azure/azure-devops-utils/master/"

while [[ $# > 0 ]]
do
  key="$1"
  shift
  case $key in
    --subscription|-su)
      subscription="$1"
      shift
      ;;
    --tenant|-t)
      tenant="$1"
      shift
      ;;
    --appid|-aid)
      appid="$1"
      shift
      ;;
    --secret|-s)
      secret="$1"
      shift
      ;;
    --resourcegroup|-rg)
      resourcegroup="$1"
      shift
      ;;
    --location|-l)
      location="$1"
      shift
      ;;
    --imageResourcegroup|-irg)
      imageResourcegroup="$1"
      shift
      ;;
    --image|-i)
      image="$1"
      shift
      ;;
    --repository|-rr)
      repository="$1"
      shift
      ;;
    --artifacts_location|-al)
      artifacts_location="$1"
      shift
      ;;
    --sas_token|-st)
      artifacts_location_sas_token="$1"
      shift
      ;;
    --custom_artifacts_location|-cal)
      custom_artifacts_location="$1"
      shift
      ;;
    --custom_sas_token|-cst)
      custom_artifacts_location_sas_token="$1"
      shift
      ;;
    --help|-help|-h)
      print_usage
      exit 13
      ;;
    *)
      >&2 echo "ERROR: Unknown argument '$key' to script '$0'"
      exit -1
  esac
done

throw_if_empty jenkins_username $jenkins_username
if [ "$jenkins_username" != "admin" ]; then
  throw_if_empty jenkins_password $jenkins_password
fi
throw_if_empty --subscription $subscription
throw_if_empty --tenant $tenant
throw_if_empty --appid $appid
throw_if_empty --secret $secret
throw_if_empty --resourcegroup $resourcegroup
throw_if_empty --location $location
throw_if_empty --imageResourcegroup $imageResourcegroup
throw_if_empty --repository $repository

# download dependencies
job_xml=$(curl -s ${custom_artifacts_location}/jenkins/vm-build-job.xml${custom_artifacts_location_sas_token})
# credentials_xml=$(curl -s ${custom_artifacts_location}/jenkins/basic-user-pwd-credentials.xml${custom_artifacts_location_sas_token})

#prepare job.xml
job_xml=${job_xml//'{insert-repository-url}'/${repository}}

echo "${job_xml}" > job.xml

#add job
run_util_script "jenkins/run-cli-command.sh" -j "$jenkins_url" -ju "$jenkins_username" -jp "$jenkins_password" -c "create-job ${job_short_name}" -cif "job.xml"

#cleanup
rm job.xml
rm jenkins-cli.jar
