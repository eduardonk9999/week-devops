# week-devops



A teoria é linda, mas DevOps se faz no terminal. Abaixo, temos um passo a passo para você sentir o que discutimos hoje na pele.

Parte 1: O Raio-X do Linux com strace
Vamos criar uma situação simulando uma aplicação que tenta ler um arquivo que não existe e entender como o Linux enxerga isso.

Abra o seu terminal Linux (pode ser WSL no Windows, Linux nativo ou Cloud Shell).
Tente ler um arquivo inexistente usando o comando cat:
cat arquivo_secreto.txt
Resultado esperado: cat: arquivo_secreto.txt: No such file or directory

A Mágica do strace: Agora vamos ver como o Sistema Operacional processou isso. Rode:
strace cat arquivo_secreto.txt
Analise a saída. Em meio a várias linhas, você encontrará algo parecido com: openat(AT_FDCWD, "arquivo_secreto.txt", O_RDONLY) = -1 ENOENT (No such file or directory)
Por que isso importa? O strace interceptou a chamada de sistema (openat) que o comando cat fez ao Kernel pedindo para ler o arquivo. O Kernel respondeu com o código de erro -1 ENOENT (Error No Entry). Quando uma aplicação travou em produção sem motivo aparente, o strace mostra exatamente em qual chamada ela congelou.

Parte 2: O Poder do Terraform na Prática
Vamos criar nossa primeira infraestrutura como código! Para facilitar e não depender de contas na nuvem, vamos usar um provedor local do Terraform.

Instale o Terraform: Siga as instruções em developer.hashicorp.com/terraform/install.
Crie um diretório para o projeto e entre nele:
mkdir meu-primeiro-terraform && cd meu-primeiro-terraform
Crie o arquivo de configuração main.tf:
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
  }
}

resource "local_file" "servidor_falso" {
  content  = "Esta é a minha infraestrutura provisionada pelo Terraform. O estado (State) está me vigiando!"
  filename = "${path.module}/servidor.txt"
}
Inicie o Terraform (init): terraform init - Leu o seu código e baixou os plugins necessários.
Planeje a Mudança (plan): terraform plan - Verificou a realidade vs o código. Exibe + create.
Aplique a Mudança (apply): terraform apply - Digite yes. O arquivo servidor.txt será criado!
A Mágica do Estado: Apague manualmente o arquivo com rm servidor.txt, rode terraform plan novamente e veja o Terraform alertar que precisa recriá-lo.
Destrua Tudo (destroy): terraform destroy para limpar o laboratório.
Próximos Passos
O chão está concretado. Você entende o Sistema Operacional e sabe que não se clica em painel.

Amanhã nós vamos empacotar nossa aplicação. A era heroica do sysadmin que instalava pacotes na mão passou.

Tema do Dia 3: Containers e Orquestração para Engenharia da Escala

(Spoiler: Você vai descobrir a maior mentira da internet: de que Kubernetes é mágica. Kubernetes é Linux).

Aviso: Traga capacete amanhã. O atrito vai aumentar.

Docker Compose =>
É um arquivo em que eu faco a definicao do meu app, dentro dele
eu coloco uma orquestracao de containers front, back e banco
e ele mesmo faz a conexao de todos
os containers.

Se você disser "Vou entrar no container" para uma pessoa engenheira sênior de verdade, ela vai rir. Sabe por quê?

Porque Container não existe.

Não existe um "objeto físico" ou uma máquina virtual chamada container. O que chamamos de container é apenas uma aplicação rodando no Linux, sobre a qual o Kernel aplicou duas "táticas de ilusão":

Namespaces (A Ilusão da Solidão):

O Linux engana a sua aplicação. Ele cria um namespace isolado e diz para o seu processo: "Você é o único que existe nesta máquina, você é o PID 1 (Process ID 1), você tem a sua própria placa de rede". A aplicação acredita e roda isolada.

Cgroups (A Coleira de Recursos):

Os Control Groups (Cgroups) limitam o uso de recursos de um processo. Você diz: "Essa aplicação só pode usar 500MB de RAM e meia CPU". Se ela tentar usar 501MB, o Kernel do Linux puxa a coleira.

Quando você junta Namespaces + Cgroups + um sistema de arquivos isolado (Rootfs) = O mercado decidiu chamar isso de "Container".

Subir 5 containers no seu notebook (usando Docker ou Podman) é fácil.

Mas como você gerencia 5.000 containers distribuídos em 100 servidores (Nodes)? Se um servidor queimar a fonte de energia de madrugada, quem move os containers dele para os outros 99 servidores que ainda estão vivos?

Isso é Orquestração. E o rei da orquestração é o Kubernetes (K8s).

O Cérebro (Control Plane) e os Trabalhadores (Worker Nodes)
O Kubernetes é dividido em duas grandes partes:

Control Plane: É a gerência. Ele não roda a sua aplicação. Ele guarda anotações (etcd), decide onde os containers vão rodar (scheduler) e expõe uma recepção para você falar com ele (API Server).

Worker Nodes: São os servidores braçais. Lá roda a sua aplicação.

O Soldado do Linux: Kubelet
Em cada Worker Node, roda um processo chamado Kubelet. Ele é quem recebe as ordens da gerência e fala pro Sistema Operacional (Linux): "Cria um Namespace e um Cgroup aqui pra essa aplicação rodar".

O Superpoder: Desired State (Estado Desejado)
O K8s trabalha com um conceito chamado Loop de Reconciliação.

Você não diz para ele: "Crie 3 cópias do meu site".

Você diz (Declarativo): "O Estado Desejado é existirem 3 cópias".

O Kubernetes então entra num loop infinito de observação:

Quantos sites eu tenho agora? 1.
Qual é o desejo? 3.
Ação: O Kubernetes manda o Kubelet subir mais 2 para empatar a realidade com o Desejo.

Kubernets => Orquestracao de containers K8s

Clusters => Um conjunto de servidores.

Pod => é um ecosistema, vai ter um IP, um container, e outras infos, um pod ele é menor unidade.
No K8s quanda pecinha, cada coisa chamamos de node.
Dentro de um POD eu posso ter mais de um container.

ETCD => Banco de Dados do k8S
