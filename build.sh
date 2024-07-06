#!/usr/bin/env bash

# Factorio server Docker image build script

set -e

# Usage function
usage() {
  echo "Usage: $0 --aws-account <account> --aws-region <region> --aws-ecr-repo <repo> --factorio-version <version>
  
  required:
    --aws-account         The AWS account where ECR is i.e. 123456789012
    --aws-ecr-repo        The AWS ECR repository name to push the Docker image to 
    --aws-region          The AWS region where ECR is i.e. us-east-1
    --factorio-version    The version of factorio to fetch i.e. 1.1.109
    
  optional:
    --docker-executable   The name of the docker executable to use in the build, default is docker

  example:
    $0 --aws-account 123456789012 --aws-region us-east-1 --aws-ecr-repo factorio --factorio-version 1.1.109
  "
  exit 1
}

# Initialize defaults
docker_executable=docker

# Check for no parameters
if [ "$#" -eq 0 ]; then
  echo "Error: parameters required."
  usage
fi

# Read command line parameters
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --aws-account) aws_account="$2"; shift ;;
    --aws-ecr-repo ) aws_ecr_repo=$2; shift ;;
    --aws-region) aws_region="$2"; shift ;;
    --docker-executable ) docker_executable="$2"; shift ;;
    --factorio-version ) factorio_version="$2"; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown parameter passed: $1"; usage ;;
  esac
  shift
done

# Check for required parameters
if [ -z "$aws_account" ] || [ -z "$aws_ecr_repo" ] || [ -z "$aws_region" ] || [ -z "$factorio_version" ]; then
  [ -z "$aws_account" ] && echo "Error: --aws-account is a required parameter."
  [ -z "$aws_ecr_repo" ] && echo "Error: --aws-ecr-repo is a required parameter."
  [ -z "$aws_region" ] && echo "Error: --aws-region is a required parameter."
  [ -z "$factorio_version" ] && echo "Error: --factorio-version is a required parameter."
  usage
fi

# Define variables
aws_ecr_url=$aws_account.dkr.ecr.$aws_region.amazonaws.com
factorio_archive=factorio_headless_x64_$factorio_version.tar.xz
factorio_archive_url=https://www.factorio.com/get-download/$factorio_version/headless/linux64

# Fetch and extract Factorio archive 
curl -sSL $factorio_archive_url -o $factorio_archive

tar xvf $factorio_archive

# Copy custom config.ini
mkdir -p factorio/config
cp -fv files/config.ini factorio/config/config.ini

# Copy custom server-settings.json
cp -fv files/server-settings.json factorio/

# Build the Docker image
$docker_executable build --platform linux/amd64 -t factorio:latest . --progress=plain

# Log on to AWS ECR
aws ecr get-login-password --region $aws_region | $docker_executable login --username AWS --password-stdin $aws_ecr_url

# Tag the Docker image
$docker_executable tag factorio:latest $aws_ecr_url/$aws_ecr_repo:latest

# Push the Docker image to ECR
$docker_executable push $aws_ecr_url/$aws_ecr_repo:latest
