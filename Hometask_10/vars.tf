variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnLXoDfmcqTHY8CUd84lMHLyeAaGqfsqffK99A8aWWJhGGCZDblNMmpIxrroftxAo/MzLphCFGFq2PDZaIwOu+dAuw5qAn/WptrUjkW/lIfGerJeJyJBBSysLSTf5g69Zz2Wnp8lXIY9RJf0aHKujQ07lSdf4UtviTFIdx7bvDJm8qw/EkzjaCPYHmM4+7i8A0s4HLI17VXREq2FC4u9A2Y9MeIt/2NfPn46jw0H2Lv6uaj3HKmEsJe9srYtL+KhncFXsftcv9o0Xb2vyBhRYixbEBS3xVR1bwOdKKr4CBtsJoztQuO0Gp9H4tL8uOO+HfrhoXQp0Za4luJBVC6MDPGivDTNuTK7x0gaf+vqaPc633+6OPQMMjh5b1S65rWiEhQVrP+wd7eiblMWZHk6YJiGSDW84xAcTuAVKQn7GWxZFcyeE/HzTReX9fO/P84u5EaOy57LloL5Zs/R8uQr93khW4eT2TTz72F7w6qtNDXl4hOWbbrd5O7GxWofwZvuHwLzveozodPgwpWGWJq7NWTV2DJ6fyCmba/MkVacV8XEl7+p8KG6DLqJQknjysUW3tCl3mQLn4v0z1CtCi6fcamPvzoC1dilkzR/2bld4lr5s3fzZBoJ/BZoQyvYVbV/FrhJqZAU/o5T0MT3IWCIYmzg2jN5kkqZ4x9vWPheQETw== smikheev@MacBook-Air-Sergei.local"
}

# Определяем хост ProxMox кластера на котором будут созданы VM
variable "proxmox_host" {
    default = "pve-01"
}

# Определяем какой темплейт будет использован для разворачивания VM
variable "template_name" {
    default = "template-debian-12-initcloud2"
}

# Опеределяем место хранения дисков VM
variable "storage_name" {
    default = "ceph_pool_1"
}

# Адрес подключения к первому хосту кластера ProxMox
variable "api_proxmox_address" {
    default = "https://192.168.101.121:8006/api2/json"
}

# Определяем наименование токена для подключения к API ProxMox
variable "api_token_id" {
    default = "deploy_tf@pam!deploy_token_id"
}

# Задаем секретный ключ токена для подключения к API ProxMox
variable "api_token_secret" {
    default = "98d9bb3f-7a41-4547-a9f3-379e5d103993"
}
