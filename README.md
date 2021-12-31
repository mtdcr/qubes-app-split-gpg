# Qubes Split GPG

These Qubes scripts allow to keep GPG private keys in a separate VM (a "vault"), allowing other VMs to use them only after being authorized. This is done by using Qubes' [qrexec framework](https://www.qubes-os.org/doc/qrexec2/) to connect a local unix socket in an AppVM to a GPG agent socket within the vault VM. Each connection creates a new GPG Agent, which only holds the keyring of the AppVM.

This was inspired by [Qubes Split SSH](https://github.com/mtdcr/qubes-app-split-ssh).

Other details:
- This was developed/tested on the debian-11 template in Qubes 4.1; it might work for other templates
- You will be prompted to confirm each request, though like split SSH you won't see what was requested
- One can have an arbitrary number of vault VMs, you just need to adjust `/rw/config/gpg-vault`.

## Differences to other implementations

- Uses stock gpg-agent on the server side
- Asks for confirmation on each new connection (handled by policy in dom0)
- No code on client side (uses systemd sockets and plain qrexec)

## Installation instructions

Copy files from this repository to various destinations (VM is the first argument). You can use `qvm-copy <filename>`.

- Dom0

  * Copy `qubes.GpgAgent.policy` to `/etc/qubes-rpc/policy/qubes.GpgAgent`

- TemplateVM for GPG-vault

  * Copy `qubes.GpgAgent` to `/etc/qubes-rpc/qubes.GpgAgent`.
  * Make `qubes.GpgAgent` executable. For example, running `sudo chmod +x /etc/qubes-rpc/qubes.GpgAgent` in the TemplateVM
  * Shutdown your TemplateVM.

- TemplateVM for AppVM:

  * Copy `qubes-gpg-agent@.service` and `qubes-gpg-agent.socket` to `/etc/systemd/user/`
  * Run `sudo systemctl --global enable qubes-gpg-agent.socket`
  * Run `sudo systemctl --global mask gpg-agent.socket`
  * Shutdown your TemplateVM.

- GPG-vault:

  * Create a directory `~/gnupg/$AppVM` for each AppVM allowed to access your GPG-vault.
  * These are regular home directories for gnupg as used with GNUPGHOME or --homedir.

- AppVM:

  * Avoid starting the stock gpg-agent automatically in case of error conditions: `echo "no-autostart" >> ~/.gnupg/gpg.conf`

- AppVM (optional):

  * Put the name of your GPG-vault into `/rw/config/gpg-vault` (default: "gpg-vault"). Remember adjusting the policy in Dom0 for non-default names.
  * Restart your AppVM.

## Troubleshooting

If something isn't working, you can check the service logs by running `sudo journalctl -t qubes.GpgAgent`.
