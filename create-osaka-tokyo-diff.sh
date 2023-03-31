#!/bin/bash

set -eu

SERVICE_URL="https://aws-new-features.s3.amazonaws.com/html/aws_services.json"
INSTANCE_TYPE_URL="https://aws-new-features.s3.amazonaws.com/html/ec2_instance_types.json"

create_diff() {
  local URL="${1}"
  local FILE
  FILE="$(basename "${URL}")"
  local FILE_PATH="${PWD}/${FILE}"

  if [ -f "${FILE_PATH}" ]; then
    rm -v "${FILE_PATH}"
  fi

  echo "${FILE%%.json} start"
  wget -O "${FILE_PATH}" "${URL}"

  diff -y -W 130 --label tokyo --label osaka \
    <(jq -r '.[]."ap-northeast-1"' "${FILE_PATH}" | sort) \
    <(jq -r '.[]."ap-northeast-3"' "${FILE_PATH}" | sort) \
    | tee "${FILE_PATH%%.json}-osaka-region-diff-from-tokyo.diff"
}

create_diff "${SERVICE_URL}"
create_diff "${INSTANCE_TYPE_URL}"


