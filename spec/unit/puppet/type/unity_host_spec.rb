# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/unity_host'

RSpec.describe 'the unity_host type' do
  it 'loads' do
    expect(Puppet::Type.type(:unity_host)).not_to be_nil
  end
end
