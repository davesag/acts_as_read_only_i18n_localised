# Acts as Read-Only I18n Localised

A variant on the `acts_as_localized` theme for when you have static seed data in your system that must be localised.

[![Build Status](https://travis-ci.org/davesag/acts_as_read_only_i18n_localised.svg?branch=master)](https://travis-ci.org/davesag/acts_as_read_only_i18n_localised) [![Code Climate](https://codeclimate.com/github/davesag/acts_as_read_only_i18n_localised/badges/gpa.svg)](https://codeclimate.com/github/davesag/acts_as_read_only_i18n_localised) [![Test Coverage](https://codeclimate.com/github/davesag/acts_as_read_only_i18n_localised/badges/coverage.svg)](https://codeclimate.com/github/davesag/acts_as_read_only_i18n_localised/coverage)

## Why use it?

1. It's designed for a specific use-case, namely the localisation of your seed data.
2. It works with the standard Rails I18n system and assumes you already have a lot of your localisation data in `config/locales/*.yml`, or you have your `i18n` stuff already set up in a database.
3. It's fast and easy.

## Example of use

In your `Gemfile`

    gem 'acts_as_read_only_i18n_localised'

In `config/locales/categories.en.yml`

    en:
      categories:
        fruits:
          name: Great fresh fruit
          description: Our fantastic range of seasonal and local fresh fruit will delight you.
        vegetables:
          name: Farm fresh veggies
          description: Our locally grown and freshly harvested veggies are simply delicious.
        meats:
          name: Farm-fresh seasonal meat
          description: >-
            Loved in life then lightly killed, our meat is locally sourced from small farms
            that meet our demanding standards.
  
In `app/models/category.rb`
  
    class Category < ActiveRecord::Base
      include ActsAsReadOnlyI18nLocalised
      validates :slug, format: {with: /^[a-z]+[\-?[a-z]*]*$/},
                       uniqueness: true,
                       presence: true
      has_many :products
      validates_associated :products
      
      acts_as_read_only_i18n_localised :name, :description
    end

This simply generates appropriate `name` and `description` methods along the lines of

    def name
      key = "#{self.class.name.pluralize}.#{slug}.name".downcase.to_sym
      return I18n.t(key)
    end

with the effect that a call to `category.name` will always return the localised name using the standard `I18n` system.

Depending on how your code is configured, `I18n` will raise a `MissingTranslationData` exception if the key does correspond to any data. Exceptions on missing keys is usually turned on in `development` and `test` but not on `staging` or `production`. See The [Rails I18n Guide](http://guides.rubyonrails.org/i18n.html) for more.

### A more complex example

Say your `categories` have their own sub `categories`.  Building on the previous example you might define the following

    class Category < ActiveRecord::Base
      include ActsAsReadOnlyI18nLocalised
      validates :slug, format: {with: /^[a-z]+[\-?[a-z]*]*$/},
                       uniqueness: true,
                       presence: true
      has_many :products
      validates_associated :products
  
      has_many :categories, foreign_key: :parent_id
      belongs_to :parent, class_name: 'Category'

      acts_as_read_only_i18n_localised :name, :description
      use_custom_slug :slug_maker
  
      def slug_maker
        reurn slug if parent.nil?
        "#{@parent.slug}.categories.#{slug}"
      end
    end

## Seeding your database

### simple case

In `db/seeds.rb` add something like

    require 'i18n'

    I18n.t(:categories).each do |key, data|
      Category.create(slug: key)
    end

### with a hierarchy

In `db/seeds.rb` add something like

    require 'i18n'

    I18n.t(:categories).each do |key, data|
      cat = Category.where(slug: key).first_or_create!
      if data[:categories]
        data[:categories].each do |inner_key, inner_data|
          Category.where(slug: inner_key, parent: cat).first_or_create!
        end
      end
    end

Or preferably something recursive, though the above will do if you are only going 1 level deep.

# Development

This gem requires Ruby version 2.0.0 or better. It is tested against the following Rubies.

* `2.0.0`
* `2.1.6`
* `2.2.4`
* `2.3.0`

Before you do anything do this:

```sh
bundle install
```

## To build the gem

    gem build acts_as_read_only_i18n_localised.gemspec

## To test it

    rspec

or

    rake

You can also run the following QA tools against the codebase if you have them installed.

* `rubocop` (on its own without any of the `codeclimate` stuff.)
* `codeclimate` (which will also run `rubocop` itself.)

## Contributing

Contributions and ideas are welcome.

If you have ideas on how to improve the codebase or feature-set, please add them as issues so they can be discussed.

For contributing code please see [CONTRIBUTING](CONTRIBUTING.md) for details on how to do that.

