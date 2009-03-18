require File.dirname(__FILE__) + '/../test_helper'

class InstrumentCategoryTest < ActiveSupport::TestCase

  fixtures :instrument_categories, :instruments

  def test_associations
    cat = instrument_categories(:petophones)
    assert_not_nil cat.instruments.find(:first)
  end

  def test_should_validate
    cat = InstrumentCategory.new
    deny cat.save
    assert cat.errors.on(:description)
    cat.description = 'suxophones'
    assert cat.save
  end

end
