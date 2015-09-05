#!/usr/bin/env bats

@test 'it can bootstrap a jspm app' {
	run prototypical jspm '/tmp/awesome_blog'
	[[ $status = 0 ]]

	[[ -d '/tmp/awesome_blog' ]]
	pushd '/tmp/awesome_blog' &>/dev/null

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

	run git status
	[[ $output = *'Initial commit'* ]]

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
