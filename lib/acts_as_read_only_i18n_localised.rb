require 'i18n'

#
# Use as follows
# class Thing < ActiveRecord::Base
#   include ActsAsReadOnlyI18nLocalised
#   validates :slug, format: {with: /^[a-z]+[\-?[a-z]*]*$/},
#                    uniqueness: true,
#                    presence: true
#   acts_as_read_only_i18n_localised :name
# end
#
# thing = Thing.create(stub: 'test')
# puts(thing.name)
#
module ActsAsReadOnlyI18nLocalised
  def self.included(base)
    base.extend(ClassMethods)
  end

  #
  # Standard Ruby idiom for auto-adding class methods
  #
  module ClassMethods

    def acts_as_read_only_i18n_localised(*attributes)
      unless methods.include?(:custom_slug)
        define_method :custom_slug do
          send(:slug) if respond_to?(:slug)
        end
      end

      attributes.each do |attribute|
        define_method attribute do
          I18n.t("#{self.class.name.gsub(/::/, '/')
                                    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                                    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                                    .tr('-', '_')}.#{send(:custom_slug)}.#{attribute}"
                 .downcase.to_sym)
        end
      end
    end

    def use_custom_slug custom_slug_method
      define_method :custom_slug do
        send(custom_slug_method) if respond_to?(custom_slug_method)
      end
    end
  end
end
