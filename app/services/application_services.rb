class ApplicationServices
  def self.find
  begin
    apps = Application.includes(:chats).all
    ServiceResponse.success(apps)
  rescue => e
    ServiceResponse.error(e.message)
  end
  end

  def self.create(name)
    begin
    token = SecureRandom.uuid
    app = Application.new(name: name, token: token)
    if app.save

      ServiceResponse.success(app)

    else

      ServiceResponse.error(app.errors.full_messages)
    end
    rescue => e
    ServiceResponse.error(e.message)
    end
  end


  def self.find_by_token(token)
    begin
    app = Application.includes(:chats).find_by(token: token)

    if app
      ServiceResponse.success(app)
    else
      ServiceResponse.error("Application not found")
    end
    rescue => e
      ServiceResponse.error(e.message)
    end
  end

  def self.update(token, params)
    begin
    app = Application.find_by(token: token)
    return ServiceResponse.error("Application not found") unless app

    if app.update(params)
      ServiceResponse.success(app)
    else
      ServiceResponse.error(app.errors.full_messages)
    end
    rescue => e
      ServiceResponse.error(e.message)
    end
  end
end
