# ✅ Rails and Graphql

# ✅ Project

- rails
- sqlite
- graphql
- spec
- ...

![image](/screem/logo.png)

# ✅ ASDF

```sh
asdf plugin add ruby         # install ruby
asdf install ruby <version>  # e.g., asdf install ruby 3.2.0
asdf global ruby <version>   # or asdf local ruby <version>
```

# ✅ Create project local

```sh
# install bundler gems
$ gem install bundler

# create project
$ rails new graphql_test --database=postgresql

# install gems
$ bundle install rails

$ add gem 'graphql'

$ rake db:create

$ rake db:migrate

$ rake db:seed
# or
$ rails db:create db:migrate db:seed

$ bundle install

$ rails generate graphql:install

# generate model
$ rails generate model Author first_name:string last_name:string date_of_birth:date --no-test-framework

$ rails generate model Book title:string author:references publication_date:integer genre:string --no-test-framework

# generate object
$ rails g graphql:object user

```

# ✅ Run docker commands

```sh

# build
$ docker compose build

# run project
$ docker compose up

$ docker compose up --build

$ docker compose run --rm app bin/rails zeitwerk:check

# setud db an migrations
$ docker compose run --rm app bin/rails db:setup

# using and check middleware
$ docker compose run --rm app bin/rails middleware

# migrate
$ docker compose run --rm app rails db:migrate RAILS_ENV=development

$ docker compose run --rm app bin/rails zeitwerk:check


# Rails generator
$ docker compose run --rm app rails generate migration CreateAudits notification:string auditable:references{polymorphic}

$ docker compose run --rm app rails generate controller Api::V1::Author


```

# ✅ Rails app Test

## ✅ Default: Run all spec files (i.e., those matching spec/**/*_spec.rb)

```sh

# ⚠️ In docker
# generate spec
$ docker compose run --rm app rails generate rspec:install

$ docker compose run --rm app rails generate rspec:model book

$ docker compose run --rm app bundle exec rspec spec/models/author_spec.rb

# or

$ docker compose run --rm app bundle exec rspec

$ docker compose run --rm app bundle exec rspec spec/models

$ docker compose run --rm app bundle exec rspec spec/models/book_spec.rb

$ docker compose run --rm app bundle exec rspec spec/models/author_spec.rb

$ docker compose run --rm app bundle exec rspec spec/queries/bool_list_spec.rb


# ⚠️ In local

# run test
$ bundle exec rspec

# run test model
$ bundle exec rspec spec/models

$ bundle exec rspec spec/models/book_spec.rb

$ bundle exec rspec spec/models/author_spec.rb

$ bundle exec rspec spec/queries/bool_list_spec.rb

$ bundle exec rspec spec --tag slow_test  #skip slow tests

$ bundle exec rspec spec/controllers/api/v1/books_controller_spec.rb

$ bundle exec rspec spec/controllers/api/v1/authos_controller_spec.rb:62

$ bundle exec rspec spec/controllers/accounts_controller_spec.rb

# Run a single example from a spec file (by line number)
$ bundle exec rspec spec/controllers/accounts_controller_spec.rb:8

$ bundle exec rspec spec/controllers/api/v1/books_controller_spec.rb

# See all options for running specs
$ bundle exec rspec --help




```

# ✅ Rails generator

```sh

# ⚠️ In docker
# generate controller api controller
$ docker compose run --rm app rails generate controller Api::V1::Author

# ⚠️ In local
# generate controller api controller
$ rails generate controller Api::V1::Author

```

# Run rocop in docker

```sh
docker compose run --rm rubocop

docker compose run --rm rubocop --auto-correct

docker compose run --rm rubocop bundle exec rubocop --auto-correct


```

# ✅ Custom Rake

```sh
# ⚠️ In docker
$ docker compose run --rm app bundle exec rake db:seed:single SEED=author_seed

$ docker compose run --rm app bundle exec rake report:generate

# ⚠️ In local
$ bundle exec rake db:seed:single SEED=author_seed
$ bundle exec rake report:generate


```

# ✅ Deploy Fly.io

```sh
# login
$ flyctl auth login
# create app
$ flyctl apps create
# publish app
$ flyctl deploy
# access console
$ flyctl ssh console

$ fly status

$ flyctl logs

$ flyctl run "bin/rails db:migrate"

$ flyctl secrets set DATABASE_URL="postgres://usuario:senha@host:porta/database"

$ flyctl ssh console -C "bin/rails db:seed"

$ flyctl ssh console -C "bin/rails db:migrate"

$ fly ssh console -a rails-graphql-sqlite

$ fly volume create lite_volume_meu_db -r REGION -n COUNT

$ fly volumes create lite_volume_meu_db -r gig -n 1

$ fly regions list

$ fly ssh console -a rails-graphql-sqlite

$ fly ssh console -a

$ fly logs -a rails-graphql-sqlite

Volume vol_v88l6pllg9lkyp7v

$ fly m destroy vol_v88l6pllg9lkyp7v

$ fly volumes destroy vol_v88l6pllg9lkyp7v


```

# ✅ Arquivo de exemplo fly.toml

```toml
app = "rails-graphql-sqlite"

[build]
  builder = "paketobuildpacks/builder:base"

[deploy]
  release_command = "bundle exec rails db:migrate"

[mounts]
  source = "lite_volume_meu_db"
  destination = "/app/db"

[[services]]
  internal_port = 3000
  processes = ["app"]
  protocol = "tcp"

  [[services.ports]]
    port = 80
    handlers = ["http"]

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]

  [[services.concurrency]]
    type = "machine"
    hard_limit = 1000
    soft_limit = 100


production:
  <<: *default
  database: db/production.sqlite3 # Caminho do banco de produção
  # database: <%= ENV.fetch("DATABASE_URL") %> # Linha comentada, não será lida

```

# ✅ links uteis

[Postgres](https://selleo.com/blog/how-to-setup-a-project-with-ruby-on-rails-postresql-and-graphql)

[Rspec](https://semaphoreci.com/community/tutorials/getting-started-with-rspec)

[GraphQL on Rails](https://evilmartians.com/chronicles/graphql-on-rails-3-on-the-way-to-perfection)

[Ruby on Rails GraphQL API](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-ruby-on-rails-graphql-api)


# ✅ Test GraphQL

- <http://localhost:3000/graphiql>

```json

/* query examples */

query{
  authors {
    id,
    firstName,
    books {
      id
    }
  }
}


/* query examples */

{
  authors {
    id
    lastName
    firstName
    dateOfBirth
      books {
        id
         author {
          id
          lastName
        }
        genre, title , publicationDate
      }
  }
}
```

```json

/* mutation  examples */

mutation {
    createBook(
        title: "Pau de arara"
        authorId: 1
        publicationDate: 19470921,
        genre:Horror
      ) {
        id
    }
}
```

```json
  mutation {
    addNote(input: {
      params: {
        title: "GraphQL notes",
        body: "A long body of text about GraphQL"
      }
    })
    {
    note {
        id
        title
        body
      }
    }
}
```

```json
  query {
    fetchNote(id: 1) {
      id
      title
      body
    }
}
```

# ✅ Development

## ✅ Axel Alexander

## ✅ My web site

- [my homepage](https://axeldeveloper.github.io/)

![image](/screem/rails_ok.png)

## ✅ Contributing

- Axel
- anomimous

## ✅ Versioning

## ✅ Authors

- **Axel Alexander** - _web site_ - [contact and contracts](http://axel-dev.herokuapp.com/)

  | Front | HTML | CSS    | VueJS | React | React |
  | ----- | ---- | ------ | ----- | ----- | ----- |
  | Back  | c#   | python | rails | go    | php   |


# ✅ License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
