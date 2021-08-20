.PHONY: quality style unit-test integ-test

check_dirs := src docker tests



run:
	docker run -t -i \
	--env HF_TASK="automatic-speech-recognition" \
	--env HF_MODEL_ID="facebook/wav2vec2-base-100h" \
	-p 8080:8080  558105141721.dkr.ecr.us-east-1.amazonaws.com/huggingface-inference-pytorch:1.8.1-cpu

build:
	docker build --tag 558105141721.dkr.ecr.us-east-1.amazonaws.com/huggingface-inference-pytorch:neuron \
							 --build-arg TRANSFORMERS_VERSION=4.9.2 \
							 --file ./docker/Dockerfile.neuron \
							 .
start:	build run

push: 
	aws ecr get-login-password \
			--region us-east-1 \
			--profile hf-sm \
		| docker login \
			--username AWS \
			--password-stdin 558105141721.dkr.ecr.us-east-1.amazonaws.com/huggingface-inference-pytorch

	docker push 558105141721.dkr.ecr.us-east-1.amazonaws.com/huggingface-inference-pytorch:1.8.1-cpu


# run tests

unit-test:
	python -m pytest -n auto --dist loadfile -s -v ./tests/unit/

integ-test:
	python -m pytest -n 2 -s -v ./tests/integ/
	# python -m pytest -n auto -s -v ./tests/integ/


# Check that source code meets quality standards

quality:
	black --check --line-length 119 --target-version py36 $(check_dirs)
	isort --check-only $(check_dirs)
	flake8 $(check_dirs)

# Format source code automatically

style:
	# black --line-length 119 --target-version py36 tests src benchmarks datasets metrics
	black --line-length 119 --target-version py36 $(check_dirs)
	isort $(check_dirs)