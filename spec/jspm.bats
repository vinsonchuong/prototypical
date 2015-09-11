#!/usr/bin/env bats

@test 'it can bootstrap a jspm app' {
	run prototypical jspm '/tmp/awesome_blog'
	[[ $status = 0 ]]

	[[ -d '/tmp/awesome_blog' ]]
	pushd '/tmp/awesome_blog' &>/dev/null

	run git status
	[[ $output = *'Initial commit'* ]]

  run cat 'LICENSE'
	[[ $output = *'The MIT License'* ]]

	run cat 'README.md'
	[[ $output = *'# Awesome Blog'* ]]
	[[ $output = *'Build Status'*'travis-ci.org/GITHUB_USERNAME/awesome_blog'* ]]
	[[ $output = *'Code Climate'*'codeclimate.com/github/GITHUB_USERNAME/awesome_blog'* ]]

	run cat '.travis.yml'
	[[ $output = *'language: node_js'* ]]
	[[ $output = *'xvfb start'* ]]

	run cat 'package.json'
	[[ $output = *'"name": "awesome_blog"'* ]]

	npm start &> server &
  while true
  do
    sleep 1
    if [[ $(cat server) = *'http://0.0.0.0:8080'* ]]
    then
      break
    fi
  done

  run curl 'http://localhost:8080'
	[[ $output = *'System.import'* ]]

	popd &>/dev/null
}

teardown() {
	if [[ -d '/tmp/awesome_blog' ]]
	then
		pushd '/tmp/awesome_blog'
    server_pid=$(ps -eo '%p:%a' | awk -F: '$2 ~ /^node.*http-server$/ {print $1}')
    if [[ $server_pid ]]
    then
      kill "$server_pid"
    fi
		popd
		rm -rf '/tmp/awesome_blog'
	fi
}
