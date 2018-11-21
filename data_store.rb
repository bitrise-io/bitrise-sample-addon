class DataStore
  def initialize
    @provisioned_apps = {}
    @request_numbers = {}
  end

  def provision_addon_for_app!(app_slug, plan, api_token)
    raise 'The requested plan is not available for the addon!' if !valid_plan?(plan)
    return @provisioned_apps[app_slug] if @provisioned_apps.keys.include?(app_slug)
    @provisioned_apps[app_slug] = {api_token: api_token, plan: plan}
    return @provisioned_apps[app_slug]
  end

  def get_app(app_slug)
    return @provisioned_apps[app_slug]
  end

  def deprovision_addon_for_app(app_slug)
    @provisioned_apps.delete(app_slug)
  end

  def update_plan!(app_slug, plan)
    raise 'The requested plan is not available for the addon!' if !valid_plan?(plan)
    return @provisioned_apps[app_slug][:plan] = plan
  end

  def valid_plan?(plan)
    return ['free', 'unlimited'].include?(plan)
  end

  def check_limit!(app_slug)
    return if @provisioned_apps[app_slug]&.[](:plan) == 'unlimited'
    @request_numbers[app_slug] = 0 if !@request_numbers[app_slug]
    if @request_numbers[app_slug] >= 5
      raise 'No more request is enabled, upgrade to `unlimited` plan for more'
    else
      @request_numbers[app_slug] = @request_numbers[app_slug] + 1
    end
  end
end