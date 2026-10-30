# Rails and Graphql

![image](/screem/logo.png)

# Peoject 
 - rails 
 - sqlite
 - graphql

- ...

# Create project local
```sh
$ gem install bundler

$ bundle install rails

$ rails new graphql_test --database=postgresql

$ rake db:create

$ add gem 'graphql'

$ bundle install

$ rails generate graphql:install

$ rails generate model Author first_name:string last_name:string date_of_birth:date --no-test-framework

$ rails generate model Book title:string author:references publication_date:integer genre:string --no-test-framework




$ rake db:migrate

$ rake db:seed

or rails db:create db:migrate db:seed

$ rails g graphql:object user

$ rails g graphql:object item

```

# Run Docker commands
```sh

# build
$ docker compose build

# run project 
$ docker compose up

# setud db an migrations
$ docker compose run --rm app bin/rails db:setup

# using and check middleware
$ docker compose run --rm app bin/rails middleware

# migrate
$ docker compose run --rm app rails db:migrate RAILS_ENV=development

$ docker compose run --rm app rails generate migration CreateAudits notification:string auditable:references{polymorphic}


```



# Test run in docker
```sh
$ docker compose run --rm app rails generate rspec:install

$ bundle exec rspec spec --tag slow_test  #skip slow tests
# run test in model
$ docker compose run --rm app rails generate rspec:model book

$ docker compose run --rm app bundle exec rspec spec/models/author_spec.rb
```

# rails generator
```sh

$ docker compose run --rm app rails generate controller Api::V1::Author
```


# Default: Run all spec files (i.e., those matching spec/**/*_spec.rb)
```sh
$ bundle exec rspec
$ bundle exec rspec spec/models

# or 

$ docker compose run --rm app bundle exec rspec

$ docker compose run --rm app bundle exec rspec spec/models

$ docker compose run --rm app bundle exec rspec spec/models/book_spec.rb

$ docker compose run --rm app bundle exec rspec spec/models/author_spec.rb

$ docker compose run --rm app bundle exec rspec spec/queries/bool_list_spec.rb
```



# Run RuboCop
```sh
bundle exec rubocop
bundle exec rubocop app/controllers
bundle exec rubocop -a
```

For Docker:
```sh
docker compose run --rm --no-deps app bundle exec rubocop
```

# Custom Rake
```sh
$ docker compose run --rm app bundle exec rake db:seed:single SEED=author_seed

$ docker compose run --rm app bundle exec rake report:generate

```




# Run a single spec file

sudo bundle exec rspec spec/controllers/api/v1/books_controller_spec.rb
sudo bundle exec rspec spec/controllers/api/v1/books_controller_spec.rb:62 
sudo bundle exec rspec spec/controllers/api/v1/authos_controller_spec.rb:62 

$ bundle exec rspec spec/controllers/accounts_controller_spec.rb

# Run a single example from a spec file (by line number)
$ bundle exec rspec spec/controllers/accounts_controller_spec.rb:8

sudo bundle exec rspec spec/controllers/api/v1/books_controller_spec.rb

# See all options for running specs
$ bundle exec rspec --help


# Examples project

[link - postgres](https://selleo.com/blog/how-to-setup-a-project-with-ruby-on-rails-postresql-and-graphql)

[link - rspec](https://semaphoreci.com/community/tutorials/getting-started-with-rspec)

[link- GraphQL on Rails](https://evilmartians.com/chronicles/graphql-on-rails-3-on-the-way-to-perfection)

[link - Ruby on Rails GraphQL API](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-ruby-on-rails-graphql-api)

# Example

- http://localhost:3000/graphiql

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
          params: { title: "GraphQL notes", body: "A long body of text about GraphQL" }})
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

## Development

    Axel Alexander

## My web site

- [my homepage](https://axeldeveloper.github.io/)

![image](/screem/rails_ok.png)

## Contributing

- Axel
- anomimous

## Versioning

## Authors

- **Axel Alexander ** - _web site_ - [contact and contracts](http://axel-dev.herokuapp.com/)

  | Front | HTML | CSS    | VueJS | React | React |
  | ----- | ---- | ------ | ----- | ----- | ----- |
  | Back  | c#   | python | rails | go    | php   |

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
