destroy_ingress:
	# destroy nginx ingress controller on eks
	kubectl delete -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/aws/deploy.yaml"
	
destroy_cluster:
	# destroy eks cluster
	@ytt -f ../config/eks > ../config/eks/cluster-ytt.yaml
	@eksctl delete cluster -f ../config/eks/cluster-ytt.yaml --profile udacity-eks
	#@rm cluster-ytt.yaml
	
destroy_iam:
	# destroy aws iam setup
	aws cloudformation delete-stack --stack-name udacity-eks-roles-and-permissions
	
destroy_all: destroy_ingress destroy_cluster destroy_iam