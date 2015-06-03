require 'test/test_helper'

class OrganizationTest < ActiveSupport::TestCase
  
  def setup
    @odyssey_networks = Organization.find 1
    @jfoa = Organization.find 2
  end
  
  test "default?" do
    assert @odyssey_networks.default?
    assert !@jfoa.default?
  end
  
  test "default" do
    assert_equal @odyssey_networks, Organization.default
    assert_not_equal @jfoa.default?, Organization.default
  end
  
  test "style_setting_value_named" do
    assert_equal "#f0f0e8", @odyssey_networks.style_setting_value_named("Page Background")
    assert_equal "#f0f0e8", @odyssey_networks.style_setting_value_named("Title Bar")
    assert_equal "#f0f0e8", @odyssey_networks.style_setting_value_named("Module Title")
    assert_equal "#f0f0e8", @odyssey_networks.style_setting_value_named("Link")
    assert_equal "#f0f0e8", @odyssey_networks.style_setting_value_named("Title Text")
    assert_equal "#f0f0e8", @odyssey_networks.style_setting_value_named("Auxilary Text")
  end
  
end
