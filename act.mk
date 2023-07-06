statoshi:docker-start## 	statoshi
## statoshi act sequence
## 	additional help example
	@touch ~/GH_TOKEN.txt
	@export $(cat ~/GH_TOKEN.txt) && act -C $(PWD) -vb  -W $(PWD)/.github/workflows/$@.yml

# vim: set noexpandtab:
# vim: set setfiletype make
