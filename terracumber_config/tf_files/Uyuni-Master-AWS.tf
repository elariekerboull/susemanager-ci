// Mandatory variables for terracumber
variable "URL_PREFIX" {
  type = string
  default = "hhttp://localhost:8080/job/uyuni-master-dev-acceptance-tests-AWS"
}

// Not really used as this is for --runall parameter, and we run cucumber step by step
variable "CUCUMBER_COMMAND" {
  type = string
  default = "export PRODUCT='Uyuni' && run-testsuite"
}

variable "CUCUMBER_GITREPO" {
  type = string
  default = "https://github.com/uyuni-project/uyuni.git"
}

variable "CUCUMBER_BRANCH" {
  type = string
  default = "master"
}

variable "CUCUMBER_RESULTS" {
  type = string
  default = "/root/spacewalk/testsuite"
}

variable "MAIL_SUBJECT" {
  type = string
  default = "Results Uyuni-Master $status: $tests scenarios ($failures failed, $errors errors, $skipped skipped, $passed passed)"
}

variable "MAIL_TEMPLATE" {
  type = string
  default = "../mail_templates/mail-template-jenkins.txt"
}

variable "MAIL_SUBJECT_ENV_FAIL" {
  type = string
  default = "Results Uyuni-Master: Environment setup failed"
}

variable "MAIL_TEMPLATE_ENV_FAIL" {
  type = string
  default = "../mail_templates/mail-template-jenkins-env-fail.txt"
}

variable "MAIL_FROM" {
  type = string
  default = "galaxy-ci@suse.de"
}

variable "MAIL_TO" {
  type = string
  default = "jgonzalez@suse.de"
}

// sumaform specific variables
variable "SCC_USER" {
  type = string
}

variable "SCC_PASSWORD" {
  type = string
}

variable "GIT_USER" {
  type = string
  default = null // Not needed for master, as it is public
}

variable "GIT_PASSWORD" {
  type = string
  default = null // Not needed for master, as it is public
}

variable "REGION" {
  type = string
  default = "eu-central-1"
}

variable "AVAILABILITY_ZONE" {
  type = string
  default = "eu-central-1a"
}

variable "KEY_FILE" {
  type = string
  default = "/home/jenkins/.ssh/id_rsa"
}

variable "KEY_NAME" {
  type = string
  default = "uyuni-jenkins"
}

variable "MY_IP" {
  type = string
}

provider "aws" {
  region     = var.REGION
}

module "cucumber_testsuite" {
  source = "./modules/cucumber_testsuite"

  product_version = "uyuni-master"

  // Cucumber repository configuration for the controller
  git_username = var.GIT_USER
  git_password = var.GIT_PASSWORD
  git_repo     = var.CUCUMBER_GITREPO
  branch       = var.CUCUMBER_BRANCH

  cc_username = var.SCC_USER
  cc_password = var.SCC_PASSWORD

  images = ["centos7", "opensuse152o", "opensuse153o", "sles15sp2o", "sles15sp3o", "ubuntu2004"]

  use_avahi    = false
  name_prefix  = "uyuni-master-"
  // domain       = "mgr.suse.de"
  from_email   = "root@suse.de"

  // no_auth_registry = "registry.mgr.suse.de"
  // auth_registry      = "registry.mgr.suse.de:5000/cucutest"
  // auth_registry_username = "cucutest"
  // auth_registry_password = "cucusecret"
  git_profiles_repo = "https://github.com/uyuni-project/uyuni.git#:testsuite/features/profiles/internal_nue"

  // server_http_proxy = "galaxy-proxy.mgr.suse.de:3128"

  host_settings = {
    controller = {
    }
    server = {
      provider_settings = {
      }
    }
    proxy = {
      provider_settings = {
      }
    }
    suse-client = {
      image = "opensuse152o"
      name = "cli-opensuse15"
      provider_settings = {
      }
    }
    suse-minion = {
      image = "opensuse152o"
      name = "min-opensuse15"
      provider_settings = {
      }
    }
    suse-sshminion = {
      image = "opensuse152o"
      name = "minssh-opensuse15"
      provider_settings = {
      }
    }
    redhat-minion = {
      image = "centos7"
      provider_settings = {
        // Since start of May we have problems with the instance not booting after a restart if there is only a CPU and only 1024Mb for RAM
        // Also, openscap cannot run with less than 1.25 GB of RAM
        memory = 2048
        vcpu = 2
      }
    }
    debian-minion = {
      name = "min-ubuntu2004"
      image = "ubuntu2004"
      provider_settings = {
      }
    }
    build-host = {
      image = "opensuse153o"
      provider_settings = {
      }
    }
// No PXE support for AWS yet
//    pxeboot-minion = {
//       image = "opensuse153o"
//      provider_settings = {
//      }
//    }
// We need to clarify if this is supported at AWS
//    kvm-host = {
//      image = "opensuse153o"
//      provider_settings = {
//      }
//    }
//    xen-host = {
//      image = "opensuse153o"
//      provider_settings = {
//      }
//    }
  }
  provider_settings = {
    create_network                       = false
    public_subnet_id                     = "subnet-0f8f5847460b0be70"
    private_subnet_id                    = "subnet-0346035ce4cd25764"
    private_additional_subnet_id         = "subnet-0459583d3361b8aa2"
    public_security_group_id             = "sg-0535a11916638b7e3"
    private_security_group_id            = "sg-01d023b03409de006"
    private_additional_security_group_id = "sg-0cbf3be126cfcf355"
    bastion_host                         = "ec2-18-157-102-83.eu-central-1.compute.amazonaws.com"
    availability_zone                    = var.AVAILABILITY_ZONE
    region                               = var.REGION
    ssh_allowed_ips                      = []
    key_name                             = var.KEY_NAME
    key_file                             = var.KEY_FILE
  }
}

output "configuration" {
  value = module.cucumber_testsuite.configuration
}
