setup: keys
	ansible-playbook -i hosts setup.yml

versions: keys
	ssh ubuntu@54.84.208.240 -- "echo -n 'Node.js '; node --version; echo -n 'npm '; npm --version; elixir --version"

keys:
	chmod 600 keys/admin2.pem
	ssh-add keys/admin2.pem

.PHONY: setup keys
