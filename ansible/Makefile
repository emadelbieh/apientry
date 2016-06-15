setup: keys
	ansible-playbook -i hosts setup.yml

verify: keys
	ssh ubuntu@54.84.208.240 -- "echo -n 'Node.js '; node --version; echo -n 'npm '; npm --version; elixir --version"

keys:
	ssh-add keys/admin2.pem

.PHONY: setup keys
