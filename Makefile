install-client:
	install -d $(DESTDIR)/etc/systemd/user
	install -m 644 qubes-gpg-agent@.service qubes-gpg-agent.socket $(DESTDIR)/etc/systemd/user/
	ln -snf /dev/null $(DESTDIR)/etc/systemd/user/gpg-agent.socket

install-vault:
	install -d $(DESTDIR)/etc/qubes-rpc
	install -m 755 qubes.GpgAgent $(DESTDIR)/etc/qubes-rpc/

install-dom0:
	install -D -m 0664 qubes.GpgAgent.policy $(DESTDIR)/etc/qubes-rpc/policy/qubes.GpgAgent

install: install-client install-vault install-dom0
