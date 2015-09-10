#!/usr/bin/env bats

@test 'it can bootstrap a basic base app' {
	run prototypical base '/tmp/awesome_blog'
	[[ $status = 0 ]]
	[[ $output = *'path=/tmp/awesome_blog'* ]]
	[[ $output = *"cd /tmp/awesome_blog"* ]]
	[[ $output = *'project_dir=awesome_blog'* ]]
	[[ $output = *'project_title=Awesome\ Blog'* ]]
	[[ $output = *'project_snake=awesome_blog'* ]]
	[[ $output = *'project_camel=awesomeBlog'* ]]
	[[ $output = *'project_class=AwesomeBlog'* ]]
	[[ $output = *'github_username=GITHUB_USERNAME'* ]]

	[[ -d '/tmp/awesome_blog' ]]
	pushd '/tmp/awesome_blog' &>/dev/null

	run git status
	[[ $output = *'Initial commit'* ]]

	run cat 'LICENSE'
	[[ $output = *'The MIT License'* ]]

	run cat 'README.md'
	[[ $output = *'# Awesome Blog'* ]]
	[[ $output = *'Build Status'*'travis-ci.org/GITHUB_USERNAME/awesome_blog'* ]]

	run cat '.travis.yml'
	[[ $output = *'language: generic'* ]]

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
