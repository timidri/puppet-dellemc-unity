# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/unity_lun'

RSpec.describe 'the unity_lun type' do
  it 'loads' do
    expect(Puppet::Type.type(:unity_lun)).not_to be_nil
  end
end
