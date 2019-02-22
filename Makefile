docker:
	docker build -t elasticsearch-aknn-plugin .

setup-env:
	virtualenv venv --python=python3
	venv/bin/pip install -r demo/pipeline/requirements.txt

index:
	venv/bin/python demo/pipeline/mnist_aknn_create.py 
	venv/bin/python demo/pipeline/mnist_es_aknn_index.py

run:
	docker run -d --rm -it -p9201:9200 --ulimit nofile=65536:65536 elasticsearch-aknn-plugin:latest

run-interactive:
	docker run --entrypoint bash --rm -it elasticsearch-aknn-plugin:latest

demo: docker run setup-env index


# curl "http://localhost:9201/mnist_images/_search?size=1" \
#     | jq -r '.hits.hits[] ._source.label, .hits.hits[] ._id'
# 
# curl "http://localhost:9201/mnist_images/mnist_images/1001/_aknn_search?k1=50&k2=10&pretty" \
#     | jq -r '.hits .hits[0:3]'
