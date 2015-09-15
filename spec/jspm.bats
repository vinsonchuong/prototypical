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

	run cat '.gitignore'
	[[ $output = *'/node_modules'* ]]
	[[ $output = *'/jspm_packages'* ]]

	run cat '.travis.yml'
	[[ $output = *'language: node_js'* ]]
	[[ $output = *'xvfb start'* ]]

	run cat 'package.json'
	[[ $output = *'"name": "awesome_blog"'* ]]
	[[ $output = *'"jspm": {'* ]]

	echo 'console.log(`Array#includes: ${[1].includes(1)}`)' >> 'app.js'

	npm start &> server &
  while true
  do
    sleep 1
    if [[ $(cat server) = *'8080'* ]]
    then
      break
    fi
  done

  run curl 'http://localhost:8080'
	[[ $output = *'System.import'* ]]

	run cat 'server'
	[[ $output = *'Array#includes: true'* ]]

	popd &>/dev/null
}

teardown() {
	if [[ -d '/tmp/awesome_blog' ]]
	then
		pushd '/tmp/awesome_blog'
		server_pid=$(ps -eo '%p:%a' | awk -F: '$2 == "node server.js" {print $1}')
    if [[ $server_pid ]]
    then
      kill "$server_pid"
    fi
		popd
		rm -rf '/tmp/awesome_blog'
	fi
}
