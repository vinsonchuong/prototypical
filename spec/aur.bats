#!/usr/bin/env bats

@test 'it can bootstrap an AUR package' {
	run prototypical aur '/tmp/awesome-package'
	[[ $status = 0 ]]

	[[ -d '/tmp/awesome-package' ]]
	pushd '/tmp/awesome-package' &>/dev/null

	run git status
	[[ $output = *'Initial commit'* ]]

	run cat 'LICENSE'
	[[ $output = *'The MIT License'* ]]

	run cat 'README.md'
	[[ $output = *'# awesome-package'* ]]
	[[ $output = *'Build Status'*'travis-ci.org/'*'/awesome-package'* ]]
	[[ $output = *'[docs](doc/awesome-package.md)'* ]]
	[[ $output = *'https://aur.archlinux.org/packages/awesome-package/'* ]]

	run cat '.travis.yml'
	[[ $output = *'language: bash'* ]]
	[[ $output = *'- realpath'* ]]
	[[ $output = *'Xvfb'* ]]
	[[ $output = *'bash-common-bundle-dependencies'* ]]
	[[ $output = *'bats spec'* ]]
	
	run cat 'PKGBUILD'
	[[ $output = *"depends=('bash-common-environment' 'bash-common-parse-options')"* ]]

	[[ -f 'doc/awesome-package.md' ]]

	PATH="$PWD/bin:$PATH" run bats spec
	[[ $status = 0 ]]
	[[ $output = *'ok 1 it says hello world'* ]]

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
