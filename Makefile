.PHONY: apply-all
apply-all:
	kubectl apply -f deployments/zookeeper
	kubectl apply -f deployments/kafka

.PHONY: delete-all
delete-all:
	kubectl delete -f deployments/zookeeper
	kubectl delete -f deployments/kafka