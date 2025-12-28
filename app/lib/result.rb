class Result
  attr_reader :value, :errors

  def initialize(success:, value: nil, errors: nil)
    @success = success
    @value   = value
    @errors  = errors
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  def self.success(value)
    new(success: true, value: value)
  end

  def self.failure(errors)
    new(success: false, errors: errors)
  end
end