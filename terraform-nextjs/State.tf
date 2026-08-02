#Configuration of state file to backend
terraform {
  backend "s3" {
    bucket = "terraform-nextjs-backend"
    key = "global/s3/backend.tfstate"
    region = "ca-central-1"
    use_lockfile = true
  }
}