#!/usr/bin/env bats

setup() {
	export GEM_HOME='/tmp/awesome_blog/.gem'
}

@test 'it can bootstrap a Rails app' {
	run prototypical rails '/tmp/awesome_blog'
	[[ $status = 0 ]]

	[[ $output = *'Successfully installed bundler'* ]]

	[[ -d '/tmp/awesome_blog' ]]
	pushd '/tmp/awesome_blog' &>/dev/null

	run bin/rails generate scaffold article title:string
	run bin/rake db:migrate
	run bin/rails runner 'Article.create(title: "First Article")'
	run bin/rails runner 'puts Article.first.title'
	[[ $output = 'First Article' ]]

	run bin/rails server --daemon
	[[ $(curl 'http://localhost:3000/articles' 2>/dev/null) = *'Listing Articles'* ]]

	mkdir '/tmp/awesome_blog/spec/features'
	cat <<-'RUBY' > '/tmp/awesome_blog/spec/features/articles_spec.rb'
	require 'rails_helper'

	RSpec.describe 'Articles' do
	  it 'can create and view an article' do
	    visit articles_path
	    click_on 'New Article'
	    fill_in 'Title', with: 'My First Article'
	    click_on 'Create Article'

	    expect(page).to have_content('Article was successfully created.')
	    expect(page).to have_content('Title: My First Article')
	  end
	end
	RUBY

	run bin/rspec
	echo "$output"
	[[ $output = *'32 examples, 0 failures, 17 pending'* ]]

  # Deploy to CF / Heroku
  # Test uglified code
  # Test .travis.yml

	run bin/spring status
	[[ $output = *'Spring is running:'* ]]

	run git status
	[[ $output = *'Initial commit'* ]]

	popd &>/dev/null
}

teardown() {
	if [[ -d '/tmp/awesome_blog' ]]
	then
		pushd '/tmp/awesome_blog'
		bin/spring stop
		if [[ -f 'tmp/pids/server.pid' ]]
		then
			kill "$(cat 'tmp/pids/server.pid')" || true
		fi

		popd
		rm -rf '/tmp/awesome_blog'
	fi

	gem clean &>/dev/null
	dropdb --if-exists 'awesome_blog_development'
	dropdb --if-exists 'awesome_blog_test'
}
