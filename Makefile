release:
	docker buildx create --name orbstack-multi --driver docker-container \
		--platform linux/amd64,linux/arm64,linux/arm/v8 --use || true
	docker buildx inspect --bootstrap
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v8 \
		-t frooko/duplicity-backup:latest --push .
	docker buildx rm orbstack-multi
