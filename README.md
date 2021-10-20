# Luvbot

O LUV_ é um BOT do Discord focado em entretenimento, passatempo e interação entre usuários.

## Disclaimer
Esse projeto foi feito em Inglês devido ao uso em um servidor em que os membros são estrangeiros.
Portanto, suas respostas no ambiente do Discord serão em Inglês. Fora as mensagens que serão exibidas, o código segue normalmente.

## Instalação

A instalação pode ser feita via `git clone` ou baixando o Zip do projeto aqui no site.
O projeto usa a linguagem Elixir e suas dependencias, portanto é necessário instalar a linguagem. Você pode baixar [aqui](https://elixir-lang.org/install.html)!

## Uso

+ Para rodar o programa, use o comando `mix run --no-halt`

O programa possui as seguintes funcionalidades até o momento:
+ **!echo**: Comando basico para testar resposta. Não implementa API.
+ **!noisebg /hexa/**: Gera um background de repetição a partir de um hexa (formato #xxxxxx sem #) usando a API [PHP-Noise](https://php-noise.com/)
+ **!qrcode (-decode) /text/**: Converte textos e links em um QRCode simples, usando as APIs [QRCOde Generator](https://goqr.me/api/) e [QR Tag](https://www.qrtag.net/api/).
+ **!(de)monsterize**: São dois comandos similares que alteram a imagem de perfil do bot. *!monsterize* gera uma imagem random usando a API [Pixel Generator](https://goqr.me/api/). *!demonsterize* desfaz a alteração.
+ **!lucky /text/**: Retorna uma resposta entre "Yes", "No" ou "Maybe" para qualquer texto que você apresenta, junto com um gif representando a resposta. A resposta é aleatória, usando a API [YesNo API](https://yesno.wtf/).
+ **!trivia /qtd/ /dificulty/ /type/**: Comando mais complexo do programa até o momento. Usando a API [Open Trivia](https://opentdb.com/api_config.php), esse comando retorna ao usuário uma série de perguntas (entre 1 e 30 perguntas). O Usuário que solicitou se torna o "Mestrando" da Trivia, recebendo via DM as respostas das perguntas. O Comando exige três parametros: *qtd* entre 1 e 30; *dificulty* entre *easy, medium, hard*; *type* entre *multiple e boolean*.
