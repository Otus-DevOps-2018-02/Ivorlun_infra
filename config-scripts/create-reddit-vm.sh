gcloud compute instances create reddit-full-app \
  --boot-disk-size=10GB \
  --image-family reddit-full \
  --image-project=infra-198317 \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure
  