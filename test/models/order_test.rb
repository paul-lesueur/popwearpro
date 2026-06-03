require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "owner-#{SecureRandom.hex(4)}@test.com", password: "password123")
    @establishment = Establishment.create!(user: @user, name: "Atelier Test")
  end

  test "document_type est receipt pour un client anonyme" do
    anonymous = @establishment.customers.create!(is_anonymous: true)
    order = @establishment.orders.create!(customer: anonymous, status: "pending")
    assert_equal :receipt, order.document_type
    assert order.receipt?
    assert_equal "Reçu", order.document_label
  end

  test "document_type est invoice pour un client nommé" do
    named = @establishment.customers.create!(firstname: "Camille", lastname: "Martin")
    order = @establishment.orders.create!(customer: named, status: "pending")
    assert_equal :invoice, order.document_type
    assert order.invoice?
    assert_equal "Facture", order.document_label
  end
end
