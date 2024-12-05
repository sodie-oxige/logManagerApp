class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :rememberable, :confirmable,
    :omniauthable, omniauth_providers: [ :google_oauth2 ]
  validates :uid, uniqueness: { scope: :provider }

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.password = Devise.friendly_token[0, 20]
      user.access_token = auth.credentials.token
      user.refresh_token = auth.credentials.refresh_token
      user.avatar = auth.info.image
      user.token_expires_at = Time.at(auth.credentials.expires_at) if auth.credentials.expires_at
      user.skip_confirmation!
    end
  end

  def refresh_access_token
    if token_expires_at.nil? || Time.current >= token_expires_at
      pp "refresh..."
      client_id = ENV["GOOGLE_CLIENT_ID"]
      client_secret = ENV["GOOGLE_CLIENT_SECRET"]
      refresh_token = self.refresh_token
      pp refresh_token

      credentials = Google::Auth::UserRefreshCredentials.new(
        client_id: client_id,
        client_secret: client_secret,
        refresh_token: refresh_token,
        scope: "https://www.googleapis.com/auth/drive.file"
      )
      pp 2

      credentials.fetch_access_token!
      pp Time.current + credentials.expires_in.seconds
      self.update(
        access_token: credentials.access_token,
        token_expires_at: Time.current + credentials.expires_in.seconds
      )
      self.update(access_token: credentials.access_token)
      pp "#{self.name} refresh!"
    else
      pp "no #{self.name} refresh!"
    end
  end
end
