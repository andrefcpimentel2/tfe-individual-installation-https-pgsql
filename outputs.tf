output "Welcome_Message" {
  value = <<SHELLCOMMANDS

ooooo   ooooo                    oooo         o8o    .oooooo.
`888'   `888'                    `888         `"'   d8P'  `Y8b
 888     888   .oooo.    .oooo.o  888 .oo.   oooo  888           .ooooo.  oooo d8b oo.ooooo.
 888ooooo888  `P  )88b  d88(  "8  888P"Y88b  `888  888          d88' `88b `888""8P  888' `88b
 888     888   .oP"888  `"Y88b.   888   888   888  888          888   888  888      888   888
 888     888  d8(  888  o.  )88b  888   888   888  `88b    ooo  888   888  888      888   888
o888o   o888o `Y888""8o 8""888P' o888o o888o o888o  `Y8bood8P'  `Y8bod8P' d888b     888bod8P'
                                                                                    888
                                                                                   o888o

░░░░░░░█▐▓▓░████▄▄▄█▀▄▓▓▓▌█ much infrastructure
░░░░░▄█▌▀▄▓▓▄▄▄▄▀▀▀▄▓▓▓▓▓▌█
░░░▄█▀▀▄▓█▓▓▓▓▓▓▓▓▓▓▓▓▀░▓▌█
░░█▀▄▓▓▓███▓▓▓███▓▓▓▄░░▄▓▐█▌ very Terraform
░█▌▓▓▓▀▀▓▓▓▓███▓▓▓▓▓▓▓▄▀▓▓▐█
▐█▐██▐░▄▓▓▓▓▓▀▄░▀▓▓▓▓▓▓▓▓▓▌█▌
█▌███▓▓▓▓▓▓▓▓▐░░▄▓▓███▓▓▓▄▀▐█ such provisioning
█▐█▓▀░░▀▓▓▓▓▓▓▓▓▓██████▓▓▓▓▐█
▌▓▄▌▀░▀░▐▀█▄▓▓██████████▓▓▓▌█▌
▌▓▓▓▄▄▀▀▓▓▓▀▓▓▓▓▓▓▓▓█▓█▓█▓▓▌█▌ Wow.
█▐▓▓▓▓▓▓▄▄▄▓▓▓▓▓▓█▓█▓█▓█▓▓▓▐█



SHELLCOMMANDS
}


output "tfe_dashboard" {
  value       = "https://${local.fqdn}:8800"
}


output "tfe_lb" {
  description = "List of public dns addresses assigned to the tfe instances"
  value       = "https://${local.fqdn}"
}

output "tfe_eip" {
  description = "List of public dns addresses assigned to the tfe instances"
  value       = "https://${aws_instance.tfe.public_ip}"
}

output "tfe_Daemon_Password" {

  value       = random_password.password.result
}

output "tfe_console_password" {

  value       = random_pet.replicated-pwd.id
}

output "tfe_db_endpoint" {
  value = aws_db_instance.ptfe.endpoint
}

output "tfe_initial_username" {
  value = var.initial_admin_username
}

output "tfe_initial_password" {
  value = random_password.tfe_initial_password.result
}

output "tfe_db_password" {
  value = random_password.db_password.result
}

output "tfe_iam_assumerole_ec2_arn" {
  value = aws_iam_role.ec2_iam_assumed_role.arn
}

# output "tfe_iam_assumerole_eks_arn" {
#   value = aws_iam_role.eks_iam_assumed_role.arn
# }

output "tfe_iam_assumerole_s3_arn" {
  value = aws_iam_role.s3_iam_assumed_role.arn
}