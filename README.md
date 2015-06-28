```
███████╗███████╗██╗  ██╗██╗████████╗
██╔════╝██╔════╝██║ ██╔╝██║╚══██╔══╝
███████╗███████╗█████╔╝ ██║   ██║
╚════██║╚════██║██╔═██╗ ██║   ██║
███████║███████║██║  ██╗██║   ██║
╚══════╝╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝

by Paul Phönixweiß aka phoenixweiss
```

# SSKit
Server Setup Kit — All you need for easy setup a new Debian 7+ server that fits popular deploy pattern for web development using Fusion Passenger, Ruby on Rails and MySQL.

## Requirements

- bash
- wget
- ssh

## How to install

Make sure you know sudo password(if any).

Install using __curl__

```
curl https://raw.githubusercontent.com/phoenixweiss/sskit/master/ssk_install.sh | sudo bash
```

Install using __wget__

```
wget -O- -q https://raw.githubusercontent.com/phoenixweiss/sskit/master/ssk_install.sh | sudo bash
```

## Notes:

- This script must be run under root privileges.
- To run the script manually don't forget to add execution rights like this:

```
chmod +x ssk_install.sh
./ssk_install.sh
```
- Script needs bash to run, because not all commands may proper run under bared shell.
- Wget is necessary to retrieve an initializer script.
