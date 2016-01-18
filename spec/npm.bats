#!/usr/bin/env bats

@test 'it can bootstrap an npm package' {
	run prototypical npm '/tmp/awesome-package'
	[[ $status = 0 ]]

	[[ -d '/tmp/awesome-package' ]]
	pushd '/tmp/awesome-package' &>/dev/null

	run git status
	[[ $output = *'Initial commit'* ]]

	run cat 'LICENSE'
	[[ $output = *'The MIT License'* ]]

	run cat 'README.md'
	[[ $output = *'# Awesome Package'* ]]
	[[ $output = *'Build Status'*'travis-ci.org/'*'/awesome-package'* ]]
	[[ $output = *'Code Climate'*'codeclimate.com/github/'*'/awesome-package'* ]]

	run cat '.gitignore'
	[[ $output = *'/node_modules'* ]]

	run cat '.travis.yml'
	[[ $output = *'language: node_js'* ]]
	[[ $output = *'Xvfb'* ]]
	[[ $output = *'npm install -g npm'* ]]

	run cat 'package.json'
	[[ $output = *'"name": "awesome-package"'* ]]
	[[ $output = *'"version": "0.0.1"'* ]]
	[[ $output = *'"license": "MIT"'* ]]
	[[ $output = *'"prepublish": "dist-es6"'* ]]

	run npm test
	[[ $status = 0 ]]
	[[ $output = *'1 spec, 0 failures'* ]]

	popd &>/dev/null
}

teardown() {
	if [[ -d '/tmp/awesome-package' ]]
	then
		pushd '/tmp/awesome-package'
		popd
		rm -rf '/tmp/awesome-package'
	fi
}
