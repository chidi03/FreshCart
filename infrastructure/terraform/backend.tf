terraform {
  backend "gcs" {
    bucket = "tf-state-chidi-cloud-security-lab-124629114"
    prefix = "week5/state"
  }
}
