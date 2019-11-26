module Mutations
  class SignInUser < BaseMutation
    null true

    argument :signin, Types::AuthProviderSignupInput, required: false

    field :token, String, null: true
    field :user, Types::UserType, null: true

    def resolve(signin: nil)
      # basic validation
      return unless signin

      user = User.find_by email: signin[:email]

      # ensures we have the correct user
      return unless user
      return unless user.authenticate(signin[:password])

      # use Ruby on Rails - ActiveSupport::MessageEncryptor, to build a token
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.credentials.secret_key_base.byteslice(0..31))
      token = crypt.encrypt_and_sign("user-id:#{ user.id }")

      { user: user, token: token }
    end
  end
end