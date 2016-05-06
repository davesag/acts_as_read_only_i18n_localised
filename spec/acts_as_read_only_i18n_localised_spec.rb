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

describe 'ActsAsReadOnlyI18nLocalised' do
  let(:model)    { TestModel.new(slug: 'test') }
  let(:key)      { :'test_model.test.name' }
  let(:expected) { 'test-result' }

  before :all do
    I18n.enforce_available_locales = false
    I18n.locale = :en
  end

  before :each do
    allow(I18n).to receive(:t).with(key).and_return(expected)
  end

  it 'has a name method' do
    expect(model).to respond_to :name
    expect(model.name).to eq expected
  end
end
