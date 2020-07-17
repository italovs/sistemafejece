# Projeto Padrão

Esse projeto visa ser o molde e modelo para todo o desenvolvimento de sistemas da GTi daqui pra frente.
Seu intuito é criar uma base comum de código para todos da empresa falaram a mesma língua e acelerar o desenvolvimento com vários módulos (pedaços) de código já prontos.


## Tecnologias

* Ruby 2.7.1

* Ruby on Rails 6.0.x

* PostgreSQL

* Yarn

## Instalação

Para a instalação do Rails, Postgres e do Yarn, veja o https://gorails.com/setup/ubuntu/20.04.

Após isso, clone o projeto e cheque se tem a versão 2.7.1 do Ruby instalada, se não, rode:

    $ rbenv install 2.7.1

Se o Rbenv reporta que não existe versão 2.7.1 do Ruby para ser instalada, siga os passos em https://github.com/rbenv/ruby-build#upgrading.

Depois, rode para instalar as dependências do projeto.

    $ bundle

Abra o projeto no VSCode e baixe as extensões recomendadas para o projeto e use as configurações do workspace.

O projeto também utiliza a gem Solargraph, que é um Servidor de Linguagem Ruby, feito para ajudar a autocompletar o código. Para baixar os dicionários da gem, rode

    $ bundle exec solargraph download-core 2.7.1
    $ bundle exec solargraph bundle

## Padrões de código

Para padronizar o código, o projeto utiliza a gem [Rubocop](https://docs.rubocop.org/rubocop/). Ele é baseado nas regras descritas em https://rubystyle.guide/, https://rails.rubystyle.guide/ e https://minitest.rubystyle.guide/. As regras desse projeto estão descritas no arquivo [.rubocop.yml](.rubocop.yml).
