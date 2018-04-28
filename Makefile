.PHONY: xw
xw:
	scp main.sh xw:/opt/sahaba/devops-shell
	scp config.sh xw:/opt/sahaba/
	scp generic.sh xw:/opt/sahaba/
