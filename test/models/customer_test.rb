require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "owner-#{SecureRandom.hex(4)}@test.com", password: "password123")
    @establishment = Establishment.create!(user: @user, name: "Atelier Test")
  end

  test "un client nommé exige prénom et nom" do
    customer = @establishment.customers.new(firstname: nil, lastname: nil)
    assert_not customer.valid?
    assert_includes customer.errors.attribute_names, :firstname
    assert_includes customer.errors.attribute_names, :lastname
  end

  test "un client nommé est valide avec prénom et nom" do
    customer = @establishment.customers.new(firstname: "Camille", lastname: "Martin")
    assert customer.valid?
  end

  test "un client anonyme est valide sans identité" do
    customer = @establishment.customers.new(is_anonymous: true)
    assert customer.valid?
    assert customer.save
  end

  test "un client anonyme reçoit une référence ANON-xxxxx" do
    customer = @establishment.customers.create!(is_anonymous: true)
    assert_match(/\AANON-\d{5}\z/, customer.anon_ref)
    assert_equal format("ANON-%05d", customer.id), customer.anon_ref
  end

  test "scope named exclut les clients anonymes" do
    named = @establishment.customers.create!(firstname: "Camille", lastname: "Martin")
    anonymous = @establishment.customers.create!(is_anonymous: true)
    assert_includes @establishment.customers.named, named
    assert_not_includes @establishment.customers.named, anonymous
  end

  test "display_name d'un anonyme est sa référence" do
    customer = @establishment.customers.create!(is_anonymous: true)
    assert_equal customer.anon_ref, customer.display_name
  end

  test "invoiceable? vrai pour un nommé identifié, faux pour un anonyme" do
    named = @establishment.customers.create!(firstname: "Camille", lastname: "Martin")
    anonymous = @establishment.customers.create!(is_anonymous: true)
    assert named.invoiceable?
    assert_not anonymous.invoiceable?
  end
end
