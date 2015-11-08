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
	[[ $output = *'Build Status'*'travis-ci.org/'*'/awesome_blog'* ]]
	[[ $output = *'Code Climate'*'codeclimate.com/github/'*'/awesome_blog'* ]]

	run cat '.gitignore'
	[[ $output = *'/node_modules'* ]]
	[[ $output = *'/jspm_packages'* ]]

	run cat '.travis.yml'
	[[ $output = *'language: node_js'* ]]
	[[ $output = *'Xvfb'* ]]

	run cat 'package.json'
	[[ $output = *'"name": "awesome_blog"'* ]]

	echo 'console.log(`Array#includes: ${[1].includes(1)}`)' >> 'server.js'
	echo 'add(`Array#includes: ${[1].includes(1)}`);' >> 'index.js'

	npm start &> server &
  while true
  do
    sleep 1
    if [[ $(cat server) = *'8080'* ]]
    then
      break
    fi
  done

	run cat 'server'
	[[ $output = *'Array#includes: true'* ]]

	run phantomjs <(cat <<-'JAVASCRIPT'
		var page = require('webpage').create();
		page.open('http://localhost:8080', function(status) {
			setTimeout(function() {
				console.log(page.evaluate(function() {
					return document.body.textContent;
				}));
				phantom.exit();
			}, 5000);
		});
	JAVASCRIPT
	)
	echo "$output"
	[[ $output = *'Hello World!'* ]]
	[[ $output = *'Hello from the API'* ]]
	[[ $output = *'Array#includes: true'* ]]

	popd &>/dev/null
}

teardown() {
	if [[ -d '/tmp/awesome_blog' ]]
	then
		pushd '/tmp/awesome_blog'
		server_pid=$(ps -eo '%p:%a' | awk -F: '$2 == "node /tmp/awesome_blog/node_modules/.bin/serve-es6" {print $1}')
		if [[ $server_pid ]]
		then
			kill "$server_pid"
		fi
		popd
		sleep 1
		rm -rf '/tmp/awesome_blog'
	fi
}
