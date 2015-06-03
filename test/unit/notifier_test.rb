require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "organization_registration" do
    @expected.subject = 'Notifier#organization_registration'
    @expected.body    = read_fixture('organization_registration')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifier.create_organization_registration(@expected.date).encoded
  end

end
