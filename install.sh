#!/bin/sh
package=./$(basename "$0")
partition=''
encryption_password=''
username=''
password=''
auto_confirm=false

function print_error () {
    echo "one or more required arguments missing:"
    print_arguments
}

function print_arguments() {
    echo "-d, --drive                   drive partition for installation"
    # echo "-r, --root                    root password"
    echo "-u, --username                username"
    echo "-p, --password                user password"
    echo "-e, --encryption-password     password to use for full disk encryption"
}

while test $# -gt 0; do
    case "$1" in
        -h | --help | help)
            echo "templates and script for customizing archinstall"
            echo " "
            echo "options:"
            echo "-y                            "
            echo "-e, --encryption-password     password to use for full disk encryption"
            echo " "
            echo "arguments:"
            print_arguments
            exit 0
            ;;
        -d | --disk)
            shift
            partition=$1
            shift
            ;;
        -u | --username)
            shift
            username=$1
            shift
            ;;
        -p | --password)
            shift
            password=$1
            shift
            ;;
        -e | --encryption-password)
            shift
            encryption_password=$1
            shift
            ;;
        -y)
	    shift
	    auto_confirm=true
    esac
done

if [ "$partition" == "" ] || [ "$username" == "" ] || [ "$password" == "" ] || [ "$encryption_password" == "" ]; then
    print_error
    exit 0
fi

if [ "$auto_confirm" == false ]; then
    echo "Disk partition: $partition"
    echo "User name: $username"
    echo "User password: $password"
    echo "Encryption password: $encryption_password"

    read -p "If this is correct, type \"YES\": " confirmation

    if [ "$confirmation" != "YES" ]; then
        echo "confirmation failed, exiting..."
        exit 0
    fi
fi

# tmp_dir=$(mktemp -d)
tmp_dir='./.temp'
cp -r ./templates/* $tmp_dir

echo "copying files to $tmp_dir"

#  edit files in place with -i
sed -i "s|PARTITION|$partition|" $tmp_dir/user_configuration.json
sed -i "s|ENCRYPTION_PASSWORD|$encryption_password|" $tmp_dir/user_credentials.json
sed -i "s|USERNAME|$username|" $tmp_dir/user_credentials.json
sed -i "s|PASSWORD|$password|" $tmp_dir/user_credentials.json
sed -i "s|PARTITION|$partition|" $tmp_dir/user_disk_layout.json

# cat $tmp_dir/user_configuration.json
# cat $tmp_dir/user_credentials.json
# cat $tmp_dir/user_disk_layout.json

sudo archinstall --config $tmp_dir/user_configuration.json --creds $tmp_dir/user_credentials.json --disk_layouts $tmp_dir/user_disk_layout.json
