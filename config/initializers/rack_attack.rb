class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  throttle('admin/login/ip', limit: 5, period: 20.minutes) do |req|
    req.ip if req.path == '/admin/session' && req.post?
  end

  self.throttled_responder = lambda do |request|
    retry_after = (request.env['rack.attack.match_data'] || {})[:period]
    headers = { 'Content-Type' => 'application/json' }
    headers['Retry-After'] = retry_after.to_s if retry_after
    body = { error: 'Too many login attempts. Please try again later.' }.to_json
    [429, headers, [body]]
  end
end
