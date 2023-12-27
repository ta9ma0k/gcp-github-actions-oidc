variable "project_id" {
  type = string
  description = "Gcp project id"
}
variable "github_repository" {
  type = string
  description = "ex) author/repository"
}
variable "service_account_id" {
  type = string 
  description = "Service account id for github actions"
}
