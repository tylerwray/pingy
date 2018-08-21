include .pingy

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
	ssh $(REMOTE_NAME) screen -dmSL pingy ./bin/pingy \
		--interval $(INTERVAL) \
		--site $(SITE) \
		--webhook $(WEBHOOK)

stop-remote:
	ssh $(REMOTE_NAME) screen -X -S pingy kill
