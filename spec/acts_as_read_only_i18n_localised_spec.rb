require 'i18n'
require 'acts_as_read_only_i18n_localised'

class TestModel
  include ActsAsReadOnlyI18nLocalised
  attr_reader :slug

  def initialize(options)
    @slug = options[:slug]
  end

  acts_as_read_only_i18n_localised :name
end

class HierarchicalTestModel < TestModel
  attr_accessor :children, :parent

  def initialize(options)
    super(options)
    unless options[:parent].nil?
      @parent = options[:parent]
      @children ||= []
      @children << self
      @slug = "#{@parent.slug}.children.#{slug}"
    end
  end
end

class CustomSlugModel
  include ActsAsReadOnlyI18nLocalised

  acts_as_read_only_i18n_localised :name
  use_custom_slug :slug_maker

  def slug_maker
    'slug_it_up'
  end
end

describe 'ActsAsReadOnlyI18nLocalised' do
  before :all do
    I18n.enforce_available_locales = false
    I18n.locale = :en
  end

  before :each do
    allow(I18n).to receive(:t).with(key).and_return(expected)
  end

  context 'with no hierarchy' do
    let(:model)    { TestModel.new(slug: 'test') }
    let(:key)      { :'test_model.test.name' }
    let(:expected) { 'test-result' }

    it 'responds to name' do
      expect(model).to respond_to :name
    end

    it 'the name has the expected value' do
      expect(model.name).to eq expected
    end
  end

  context 'with simple hierarchy' do
    let(:parent) { HierarchicalTestModel.new(slug: 'parent') }

    context 'parent' do
      let(:key)      { :'hierarchical_test_model.parent.name' }
      let(:expected) { 'test-parent-result' }

      it 'responds to name' do
        expect(parent).to respond_to :name
      end

      it 'the name has the expected value' do
        expect(parent.name).to eq expected
      end
    end

    context 'child' do
      let(:child) { HierarchicalTestModel.new(slug: 'child', parent: parent) }
      let(:key)      { :'hierarchical_test_model.parent.children.child.name' }
      let(:expected) { 'test-child-result' }

      it 'responds to name' do
        expect(child).to respond_to :name
      end

      it 'the name has the expected value' do
        expect(child.name).to eq expected
      end
    end
  end

  context 'with custom slug maker' do
    let!(:model)   { CustomSlugModel.new }
    let(:key)      { :"custom_slug_model.slug_it_up.name" }
    let(:expected) { 'test-custom-result' }

    it 'responds to name' do
      expect(model).to respond_to :name
    end

    it 'the name has the expected value' do
      expect(model.name).to eq expected
    end
  end

  context 'with access to String.pluralize', verify_stubs: false do
    let(:model)    { TestModel.new(slug: 'test') }
    let(:key)      { :"test_models.test.name" }
    let(:expected) { 'test-custom-result' }

    before :each do
      allow_any_instance_of(String).to receive(:pluralize)
        .and_return('test_models')
    end

    it 'the name has the expected value' do
      expect(model.name).to eq expected
    end
  end

  context 'with access to self.table_name', verify_stubs: false do
    let(:model)    { TestModel.new(slug: 'test') }
    let(:key)      { :"test_models.test.name" }
    let(:expected) { 'test-custom-result' }

    before :each do
      allow(model).to receive(:table_name).and_return('test_models')
    end

    it 'the name has the expected value' do
      expect(model.name).to eq expected
    end
  end
end
