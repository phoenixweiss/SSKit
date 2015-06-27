# SSKit
Server Setup Kit — All you need for easy setup a new Debian 7+ server that fits popular deploy pattern for web development using Fusion Passenger, Ruby on Rails and MySQL.

## How to install

Make sure you know sudo password(if any).

Install using __curl__

```
curl -O https://raw.githubusercontent.com/phoenixweiss/sskit/master/ssk-install.sh && sudo ./ssk-install.sh
```

Install using __wget__
```
wget https://raw.githubusercontent.com/phoenixweiss/sskit/master/ssk-install.sh -v -O ssk-install.sh && chmod +x ssk-install.sh && sudo ./ssk-install.sh
```

## Notes:

- This script must be run under root privileges.
- To run the script manually don't forget to add execution rights like this:
  ```
  chmod +x ssk-install.sh
  ./ssk-install.sh
  ```
- The only prerequisite is bash, because not all commands may proper run under bared shell.
