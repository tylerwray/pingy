TAG=$(shell git describe --abbrev=0 --tags)

publish:
	docker build -t wraytw/pingy:$(TAG) .
	docker push wraytw/pingy:$(TAG)

compile:
	GOOS=linux GOARCH=amd64 go build

clean:
	rm -rf ./pingy

deploy: compile
	scp -r ./pingy rrlogan-health:/home/ec2-user/bin
	make stop-remote
	make start-remote
	make clean

start-remote:
	ssh rrlogan-health screen -dmSL pingy ./bin/pingy --interval 12h --site http://renaissancelogan.com --webhook https://hooks.slack.com/services/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

stop-remote:
	ssh rrlogan-health screen -X -S pingy kill
