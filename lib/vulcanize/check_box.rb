module Vulcanize
  # Used to coerce input from <input type="checkbox" name="name">
  # which by befault will send the following
  #     checked:   {'name' => 'on'}
  #     unchecked: {}
  
  CheckBox = Object.new

  def CheckBox.new(raw)
    return true if raw == 'on'
    fail ArgumentError
  end
end
