require 'test/test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @odyssey_networks = Organization.find 1
    @jfoa = Organization.find 2
    @superuser = User.find 1
    @tron = users(:tron)
    @harvey = users(:harvey)
  end
  
  test "full_name" do
    assert_equal "Tron Fu", @tron.full_name
  end
  
  test "member_of?" do
    assert !@tron.member_of?(@odyssey_networks)
    assert !@tron.member_of?(@jfoa)
    assert @harvey.member_of?(@jfoa)
    assert !@harvey.member_of?(@odyssey_networks)
  end
  
  test "friend_with?" do
    assert @tron.associated_with?(@odyssey_networks)
    assert !@tron.associated_with?(@jfoa)
    assert !@harvey.associated_with?(@odyssey_networks)
    assert @harvey.associated_with?(@jfoa)
  end
  
  
end
