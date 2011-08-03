ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
  payload.delete(:params)
  extra_hash = {:total_runtime => (finish - start) * 1000}
  payload.merge! extra_hash
  ControlCenter::Response.create(payload)
end
