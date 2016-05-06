# Acts as Read-Only i18n Localised

A variant on the `acts_as_localized` theme for when you have static seed data in your system that must be localised.

## Why use it?

1. It's designed for a specific use-case, namely the localisation of your seed data.
2. It works with the standard Rails I18n system and assumes you already have a lot of your localisation data in `config/locales/*.yml`, or you have your `i18n` stuff already set up in a database.
3. It's fast and easy.

## Example of use

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
      validates :slug, format: {with: /^[a-z]+[\-?[a-z]*]*$/},
                       uniqueness: true,
                       presence: true
      has_many :products
      validates_associated :products
      
      acts_as_read_only_i18n_localised
  
      localise :name, :description
    end

The `localise` method simply generates appropriate `name` and `description` methods along the lines of

    def name
      key = "#{self.class.name.pluralize}.#{slug}.name".downcase.to_sym
      return I18n.t(key)
    end

with the effect that a call to `category.name` will always return the localised name using the standard `I18n` system.

Depending on how your code is configured, `I18n` will raise a `MissingTranslationData` exception if the key does correspond to any data. Exceptions on missing keys is usually turned on in `development` and `test` but not on `staging` or `production`. See The [Rails I18n Guide](http://guides.rubyonrails.org/i18n.html) for more.

## Seeding your database

In `db/seeds.rb` add something like

    require 'i18n'

    I18n.t(:categories).each do |key, data|
      Category.create(slug: key)
    end

