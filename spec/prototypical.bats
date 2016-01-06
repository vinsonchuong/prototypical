#!/usr/bin/env bats

teardown() {
	rm -rf "${BATS_TEST_DIRNAME}/../lib/recipe"
}

@test 'it installs the given recipe' {
	local recipe_dir="${BATS_TEST_DIRNAME}/../lib/recipe"
	mkdir "$recipe_dir"
	cat <<-'EOF' > "${recipe_dir}/install"
	echo "Recipe: $1"
	EOF
	chmod +x "${recipe_dir}/install"

	run prototypical 'recipe' "${BATS_TMPDIR}/awesome_blog"
	echo "$output"
	[[ $status = 0 ]]
	[[ $output = "Recipe: ${BATS_TMPDIR}/awesome_blog" ]]
}

@test 'it shows an error message when an invalid recipe is given' {
	run prototypical 'invalid-recipe' "${BATS_TMPDIR}/awesome_blog"
	[[ $status = 1 ]]
	[[ $output = 'Please specify a valid recipe.' ]]
	[[ ! -d '${BATS_TMPDIR}/awesome_blog' ]]
}
