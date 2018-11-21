class DataStore
  App = Struct.new(:slug, :plan, :api_token){}

  def initialize
    @provisioned_apps = []
    @request_numbers = {}
  end

  def provision_addon_for_app!(app_slug, plan, api_token)
    raise 'The requested plan is not available for the addon!' if !valid_plan?(plan)
    app = get_app(app_slug)
    return app if app != nil
    @provisioned_apps << App.new(app_slug, plan, api_token)
    return @provisioned_apps.last
  end

  def get_app(app_slug)
    @provisioned_apps.each do |app|
      return app if app.slug == app_slug
    end
    return nil
  end

  def deprovision_addon_for_app(app_slug)
    @provisioned_apps.delete_if {|app| app.slug == app_slug }
  end

  def update_plan!(app_slug, plan)
    raise 'The requested plan is not available for the addon!' if !valid_plan?(plan)
    app = get_app(app_slug)
    return app.plan = plan
  end

  def valid_plan?(plan)
    return ['free', 'unlimited'].include?(plan)
  end

  def check_limit!(app_slug)
    app = get_app(app_slug)
    return if app.plan == 'unlimited'
    @request_numbers[app_slug] = 0 if !@request_numbers[app_slug]
    if @request_numbers[app_slug] >= 5
      raise 'No more request is enabled, upgrade to `unlimited` plan for more'
    else
      @request_numbers[app_slug] = @request_numbers[app_slug] + 1
    end
  end
end