class ServiceResponse
  attr_reader :success, :data, :error

  def initialize(success:, data: nil, error: nil)
    @success = success
    @data = data
    @error = error
  end

  def self.success(data = nil)
    new(success: true, data: data)
  end

  def self.error(error)
    new(success: false, error: error)
  end

  def success?
    @success
  end

  def to_h
    if success
      { success: true, data: data }
    else
      { success: false, error: error }
    end
  end
end
