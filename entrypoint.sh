#!/bin/bash

if [ "${RUNNER_DEBUG}" = "1" ] ; then
  set -x
fi

# install actionlint
export ACTIONLINT_VERSION=1.6.22
export OSTYPE=linux-gnu
wget -O - -q https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash | sh -s -- ${ACTIONLINT_VERSION} /usr/local/bin/

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}" || exit
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# shellcheck disable=SC2086
actionlint -oneline ${INPUT_ACTIONLINT_FLAGS} \
    | reviewdog \
        -efm="%f:%l:%c: %m" \
        -name="${INPUT_TOOL_NAME}" \
        -reporter="${INPUT_REPORTER}" \
        -filter-mode="${INPUT_FILTER_MODE}" \
        -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
        -level="${INPUT_LEVEL}" \
        ${INPUT_REVIEWDOG_FLAGS}
exit_code=$?

exit $exit_code
