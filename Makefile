docker:
	sudo docker build -t elasticsearch-aknn-plugin .

run:
	sudo docker run -d --rm -it -p9201:9200 --ulimit nofile=65536:65536 elasticsearch-aknn-plugin:latest

run-interactive:
	sudo docker run --entrypoint bash --rm -it elasticsearch-aknn-plugin:latest
