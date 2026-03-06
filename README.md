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

Pipeline => Cano, vc tem uma sequencia de coisas que vai passar por ele.

CI - CD
GitHub
GitLab
Tudo isso é CI - Continus integration =>
Neles a gente configura uma pipeline,
e o codigo vai comecar passar por staps,
Ex: Teste de código, Teste unitarios, com isso temos uma qualidade de código antes de de finalizar o deploy.
Tudo isso é CD - Continus Delivery =>
Deploy, QA, Homolog, Prod....

Uma pessoa desenvolvedora pode escrever o código mais genial, limpo e rápido do mundo. Se esse código ficar commitado no repositório (Git) por semanas, esperando uma "janela de deploy" no sábado à noite, esse código não entregou valor nenhum para o cliente da empresa.

Antigamente, juntava-se o trabalho de 50 pessoas desenvolvedoras durante 3 meses para fazer um "Grande Release". O resultado?

O Merge Hell (Inferno da Mesclagem). O sistema quebrava inteiro porque as peças não encaixavam.

1. A Cura: CI (Continuous Integration / Integração Contínua)
A regra de ouro moderna é: Integração Pequena e Frequente.

Ao invés de esperar 3 meses, a pessoa desenvolvedora envia código para o repositório principal 5 vezes por dia.

O CI é um pipeline (esteira automatizada) que funciona como um "Inspetor de Qualidade". Toda vez que código novo entra, a esteira (ex: GitHub Actions, GitLab CI):

1. Baixa o código
2. Roda a compilação (Build)
3. Roda Testes Unitários e de Integração: Garante que o recurso novo não quebrou o carrinho de compras antigo.
4. Verifica Segurança (Sec): Checa se existem senhas chumbadas no código ou bibliotecas com vulnerabilidades conhecidas (CVEs).
5. Empacota (Docker Build): Cria a imagem nova do Container e armazena no registro (Docker Hub, AWS ECR).
Se qualquer etapa falhar, a esteira fica VERMELHA e bloqueia a entrega. Nós resolvemos problemas enquanto eles são pequenos.

2. O Destino: CD (Continuous Delivery/Deployment)
A imagem do Container está pronta. Agora ela precisa chegar na Produção (no cluster Kubernetes).

Fazer Deploy manualmente, trocando a versão no painel e torcendo para funcionar, é a definição de amadorismo.

CD é ter a infraestrutura automatizada puxando ou aplicando a versão nova de forma invisível para quem usa.

O Fim do Medo da Sexta-Feira! (Estratégias de Deploy Seguras):

Rollback em 1 clique: Se o Deploy quebrar a produção, nós não consertamos na produção. Nós voltamos para a versão anterior (git revert / ArgoCD sync) em segundos.

Canary Release (Canário): Não atualiza tudo de uma vez. Manda 5% do tráfego para a versão Nova. Observa. Se estiver dando erro, volta. Se estiver bom, aumenta para 20%, depois 100%. Ninguém percebeu.

CLAUDE
Você já ouviu "coloca na Cloud" como se fosse apertar um botão mágico. Mas a Cloud é uma infraestrutura real, com servidores físicos em data centers espalhados pelo planeta. Entender como ela funciona é o que separa quem "usa" de quem domina.

1. O que é Cloud Computing de Verdade?
Cloud é alugar computação, armazenamento e rede de outra empresa (AWS, GCP, Azure) sob demanda, pagando pelo que usar. Simples assim.

A mágica não é "onde" roda, mas como roda:

Elasticidade: Escala de 2 para 200 máquinas automaticamente quando o tráfego da Black Friday chega. E volta para 2 quando acaba. Sem ligar para o data center pedindo servidor.
Pay-as-you-go: Pagou por 3 horas de GPU para treinar um modelo? Desligou? Parou de pagar.
Disponibilidade Global: Sua aplicação pode rodar simultaneamente em São Paulo, Virginia e Frankfurt.
2. A Anatomia: Regiões e Zonas de Disponibilidade
Imagine a AWS como uma rede de shopping centers pelo mundo:

Região (Region): Uma cidade inteira (ex: sa-east-1 = São Paulo). Cada região tem múltiplos data centers.
Zona de Disponibilidade (AZ): Cada data center isolado dentro da região. Se um pegar fogo, os outros continuam operando.
Regra de ouro: Nunca rode tudo numa AZ só. Distribua seus Pods/instâncias em pelo menos 2 AZs. Assim, se uma cair, sua aplicação continua no ar.

3. IaaS vs PaaS vs SaaS — O Modelo de Responsabilidade
Quanto mais alto o nível do serviço, menos você gerencia (e menos controle tem):

| Modelo | Você gerencia | Exemplo | |--------|--------------|---------| | IaaS (Infrastructure as a Service) | OS, runtime, app, dados | EC2, GCE, Azure VMs | | PaaS (Platform as a Service) | Apenas app e dados | Heroku, Cloud Run, App Engine | | SaaS (Software as a Service) | Nada (só usa) | Gmail, Slack, Notion |

Para DevOps, o sweet spot geralmente é entre IaaS e PaaS: Kubernetes gerenciado (EKS, GKE, AKS). Você controla os containers, mas não precisa instalar o cluster na mão.

4. Serviços Gerenciados: Não Reinvente a Roda
A Cloud oferece serviços prontos para problemas comuns:

Banco de Dados: RDS (PostgreSQL/MySQL gerenciado), DynamoDB (NoSQL)
Armazenamento: S3 (objetos/arquivos), EBS (disco de VM)
Mensageria: SQS (filas), SNS (notificações), EventBridge
Container Registry: ECR (AWS), GCR (Google) — onde suas imagens Docker ficam guardadas
DNS e CDN: Route53 + CloudFront (AWS), Cloud DNS + Cloud CDN (Google)
A regra: Se a Cloud oferece gerenciado, use gerenciado. Rodar seu próprio PostgreSQL numa EC2 é pedir para ter pesadelo com backup, patching e failover.

5. Custo: O Monstro Silencioso
A Cloud cobra por tudo: CPU, RAM, tráfego de rede (especialmente saída!), armazenamento, até DNS queries.

Dicas de sobrevivência financeira:

Tags: Marque todos os recursos com projeto/time/ambiente. Sem tags = sem controle de custo.
Alertas de billing: Configure alarmes para gastar mais que X reais/mês.
Spot/Preemptible instances: VMs até 90% mais baratas, mas a Cloud pode tomá-las de volta a qualquer momento. Perfeitas para workloads stateless com Kubernetes.
Reserved Instances / Committed Use: Comprometa-se por 1-3 anos e economize 40-70% vs on-demand.
6. Cloud + Kubernetes + CI/CD = O Trinômio Moderno
O fluxo real de uma empresa moderna:

Terraform provisiona o cluster Kubernetes na Cloud (EKS/GKE/AKS)
CI/CD (GitHub Actions) builda a imagem Docker e faz push para o Container Registry
Kubernetes no cluster Cloud recebe o deploy e distribui entre as AZs
Auto-scaling ajusta o número de Pods e Nodes conforme a demanda
Isso é o que estamos montando ao longo da semana. Cada dia foi uma peça desse quebra-cabeça.

