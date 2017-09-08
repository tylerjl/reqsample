require 'spec_helper'

describe ReqSample do
  describe 'constants' do
    it 'should have a VERSION constant' do
      expect(subject.const_get('VERSION')).to_not be_empty
    end
  end
end
