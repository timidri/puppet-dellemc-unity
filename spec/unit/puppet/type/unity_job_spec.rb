# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/unity_job'

RSpec.describe 'the job type' do
  it 'loads' do
    expect(Puppet::Type.type(:unity_job)).not_to be_nil
  end
end
