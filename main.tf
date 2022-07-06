terraform{
	required_providers{
		docker = {
			source = "kreuzwerker/docker"
			version = ">= 2.13.0"
		}
	}
}

variable "APP_ID" {
    description = "APP ID used for oc transpo api authentication"
    type = string
    sensitive = true
}

variable "API_KEY" {
    description = "API KEY used for oc transpo api authentication"
    type = string
    sensitive = true
}

provider "docker"{
	host    = "npipe:////.//pipe//docker_engine"
}

resource "docker_network" "devops-network" {
	name = "devops-network"
}

resource "docker_image" "devops-external" {
	name = "devops-external:latest"
	build {
		path = "./external"
	}
}

resource "docker_image" "devops-api" {
	name = "devops-api:latest"
	build {
		path = "./api"
	}
}

resource "docker_image" "devops-proxy" {
	name = "devops-proxy:latest"
	build {
		path = "./haproxy"
	}
}

resource "docker_container" "devops-external" {
	name = "devops-external"
	image = docker_image.devops-external.latest
	networks_advanced {
		name = "devops-network"
	}
	depends_on = [
    	docker_network.devops-network
  	]
}

resource "docker_container" "devops-api" {
	name = "devops-api"
	image = docker_image.devops-api.latest
	env = [var.APP_ID, var.API_KEY]
	networks_advanced {
		name = "devops-network"
	}
	depends_on = [
    	docker_network.devops-network
  	]
}

resource "docker_container" "devops-proxy" {
	name = "devops-proxy"
	image = docker_image.devops-proxy.latest
	networks_advanced {
		name = "devops-network"
	}
	ports {
		internal = 80
		external = 80
	}
	depends_on = [
    	docker_network.devops-network
  	]
}