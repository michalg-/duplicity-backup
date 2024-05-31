release:
	docker buildx build --platform linux/arm64 -t duplicity-backup:latest .
	docker tag duplicity-backup:latest frooko/duplicity-backup:latest
	docker push frooko/duplicity-backup:latest
