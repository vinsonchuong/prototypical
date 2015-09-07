#!/usr/bin/env bats

@test 'it can bootstrap a basic base app' {
	run prototypical base '/tmp/awesome_blog'
	[[ $status = 0 ]]

	[[ -d '/tmp/awesome_blog' ]]
	pushd '/tmp/awesome_blog' &>/dev/null

  run cat '/tmp/awesome_blog/LICENSE'
	[[ $output = *'The MIT License'* ]]

	run git status
	[[ $output = *'Initial commit'* ]]

	popd &>/dev/null
}

teardown() {
	if [[ -d '/tmp/awesome_blog' ]]
	then
		pushd '/tmp/awesome_blog'
		popd
		rm -rf '/tmp/awesome_blog'
	fi
}
