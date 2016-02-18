# Hyperion Controller for Alfred 2

> Quickly control your LED-strip connected to hyperion with Alfred through SSH.

![Index](/screenshots/index.png)
![Effects](/screenshots/effects.png)

## Installation
1. **[Download the workflow](https://github.com/Nosskirneh/hyperion-alfred-workflow/releases/download/v1.0/Hyperion.Controller.alfredworkflow)** 

2. Configure the IP and user at the first lines located in hyperion.sh

3. Add your local id_rsa.pub to the authorized_keys on the remote machine to be able to login without password. Tip: use **[ssh-copy-id](http://linux.die.net/man/1/ssh-copy-id)

## Acknowledgements
This script is using markokaestner's **[Bash Workflow Handler](https://github.com/markokaestner/bash-workflow-handler)**