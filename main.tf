vim main.tf
#provider da aws, ou seja quero criar coisas na aws


provider "aws" {
	region = "us-east-1"
}

# resource = pega coisas, busca infos, habilidades que voce pega para criar uma instancia
resource "aws_instance" "servidor_de_planta" {
	ami = "ami-0c101d26f14fa7fd"
	instance_type = "t2.micro"
	
	tags = {
		Name = "ServidorDePlanta"
	}


}
