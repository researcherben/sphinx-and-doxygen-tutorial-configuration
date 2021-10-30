
docker: docker_build docker_run

docker_build:
	docker build -t sphdoxy .
docker_run:
	docker run -it --rm -v `pwd`:/scratch sphdoxy
