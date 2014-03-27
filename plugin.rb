# name: omniauth-mindvalley-discourse
# about: Authenticate with discourse with Mindvalley
# version: 0.1.0
# author: parasquid

gem 'omniauth-mindvalley'


class MindvalleyAuthenticator < ::Auth::Authenticator

  CLIENT_ID = '1111111'
  CLIENT_SECRET = 'AUSTRALIASNAKESALAD'

  def name
    'mindvalley'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    # grap the info we need from omni auth
    data = auth_token[:info]
    name = data["first_name"]
    mv_uid = auth_token["uid"]
    email = data['email']

    # plugin specific data storage
    current_info = ::PluginStore.get("mv", "mv_uid_#{mv_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = name
    result.extra_data = { mv_uid: mv_uid }
    result.email = email

    result
  end

  def after_create_account(user, auth)
    data = auth[:extra_data]
    ::PluginStore.set("mv", "mv_uid_#{data[:mv_uid]}", {user_id: user.id })
  end

  def register_middleware(omniauth)
    omniauth.provider :mindvalley,
     CLIENT_ID,
     CLIENT_SECRET
  end
end


auth_provider :title => 'with Mindvalley Accounts',
    :message => 'Log in via Mindvalley Accounts (Make sure pop up blockers are not enabled).',
    :frame_width => 920,
    :frame_height => 800,
    :authenticator => MindvalleyAuthenticator.new


# We ship with zocial, it may have an icon you like http://zocial.smcllns.com/sample.html
#  in our current case we have an icon for vk
register_css <<CSS

.btn-social.vkontakte {
  background: #46698f;
}

.btn-social.vkontakte:before {
  content: "N";
}

CSS