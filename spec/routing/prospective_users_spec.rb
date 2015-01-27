require 'spec_helper'

describe '' do
  it 'routes root to the angular engine' do
    expect(post: "/v1/prospective_users").to route_to(
      controller: "v1/prospective_users",
      action: 'create',
      format: 'json'
    )
  end
end
