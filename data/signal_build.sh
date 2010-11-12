#!/bin/bash


if [ -z $1 ]
then
  echo ""
  echo "#############################################"
  echo "Ruby Version and RVM Gemset Name are missing!"
  echo "#############################################"
  echo ""
  exit 0
else
  desired_ruby=$1
fi

if [ -z $2 ]
then
  echo ""
  echo "##############################"
  echo "RVM Gemset name missing!"
  echo "##############################"
  echo ""
  exit 0
else
  project_name=$2
fi

echo Ruby Version: $desired_ruby
echo RVM Gemset: $project_name


# remove annoying "warning: Insecure world writable dir"
function remove_annoying_warning() {
  chmod go-w $HOME/.rvm/gems/$desired_ruby{,@{global,$project_name}}{,/bin} 2>/dev/null
}

# enable rvm for ruby interpreter switching
source $HOME/.rvm/scripts/rvm || exit 1

# show available (installed) rubies (for debugging)
rvm list

# install our chosen ruby if necessary
rvm list | grep $desired_ruby > /dev/null || rvm install $desired_ruby || exit 1

# use our ruby with a custom gemset
rvm use $desired_ruby@$project_name --create
remove_annoying_warning

# install bundler if necessary
gem list --local bundler | grep bundler || gem install bundler || exit 1

# debugging info
echo USER=$USER && ruby --version && which ruby && which bundle

# conditionally install project gems from Gemfile
bundle check || bundle install || exit 1

# remove the warning again after we've created all the gem directories
remove_annoying_warning

# finally, run rake
rake build
