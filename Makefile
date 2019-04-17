.PHONY: build-cfn build-controller build-cluster clean-cfn clean-cluster clean-all

build-cluster:
	eksctl create cluster --config-file demo-cluster.yml
	export MESH_REGION=us-east-1; export MESH_NAME=bookinfo-mesh; export IMAGE_NAME=602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon/aws-app-mesh-inject:v0.1.0; curl https://raw.githubusercontent.com/aws/aws-app-mesh-inject/master/hack/install.sh | bash

build-cfn:
	kubectl apply -f bookinfo-appmesh-ns-only.yml
	aws cloudformation deploy --template-file bookinfo-appmesh-mesh-cfn.yml --stack-name bookinfo-appmesh
	echo "Waiting to make sure everything is running"; sleep 30
	kubectl apply -f bookinfo-appmesh-app.yml

clean-cfn:
	aws cloudformation delete-stack --stack-name bookinfo-appmesh
	kubectl delete ns appmesh-bookinfo

clean-cluster:
	eksctl delete cluster demo-cluster

clean-all: clean-cfn clean-cluster