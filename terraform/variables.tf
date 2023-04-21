/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


variable "folder_id" {
    sensitive = true
}
variable "billing_account" {
  sensitive = true
}
variable "cluster_name_suffix" {
  description = "A suffix to append to the default cluster name"
  default     = ""
}

variable "region" {
  description = "The region to host the cluster in"
  default = "us-central1"
}

variable "ip_range_pods" {
  description = "The secondary ip range to use for pods"
  default = "10.0.0.0/16"
}

variable "ip_range_services" {
  description = "The secondary ip range to use for services"
  default = "10.1.0.0/24"
}

variable "compute_engine_service_account" {
  description = "Service account to associate to the nodes in the cluster"
  default=""
}

variable "dns_project"{
    description = "the gcp project id that hosts public dns zone"
}

variable "project_id"{
    description = "new project id"
}
