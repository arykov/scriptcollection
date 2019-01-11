#!/bin/bash
#Script to help with publishing local maven repo to artifactory
help () {
  echo "Use: upload_to_artifactory.sh -u user:password -a artifactory_url -r source of artifacts to be uploaded
For example to upload to your artifactory everything from your local repo 
  upload_to_artifactory.sh -u john:johnpassword -a https://a.xyz.com/artifactory_myrepo -r /home/john/.m2/repository/
If you don't provide password curl should prompt you"
  
  exit 1
}
while getopts ":r:u:a:h:" opt; do
  case $opt in
    r) root_dir="$OPTARG"
    ;;
    a) base_url="$OPTARG"
    ;;
    u) user_password="$OPTARG"
    ;;
    h) help
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z "$root_dir" ] || [ -z "$base_url" ] || [ -z "$user_password" ] ; then
    help
fi
find ${root_dir} -type f | while read line; do
    url=${base_url}/`realpath --relative-to=${root_dir} ${line}`
    curl -u ${user_password} -X PUT "${url}" -T ${line}
done
