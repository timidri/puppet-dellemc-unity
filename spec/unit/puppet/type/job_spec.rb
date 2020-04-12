# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/job'

RSpec.describe 'the job type' do
  it 'loads' do
    expect(Puppet::Type.type(:job)).not_to be_nil
  end
end
