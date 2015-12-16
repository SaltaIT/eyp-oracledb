require 'spec_helper'
describe 'oracledb' do

  context 'with defaults for all parameters' do
    it { should contain_class('oracledb') }
  end
end
