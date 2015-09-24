require 'spec_helper'

describe String do
  context ".underscore" do
    it "should snake_case string" do
      expect('pipo'.underscore).to eq 'pipo'
      expect('pi_po'.underscore).to eq 'pi_po'
      expect('piPo'.underscore).to eq 'pi_po'
      expect('PiPo'.underscore).to eq 'pi_po'
      expect('PiPO'.underscore).to eq 'pi_po'
      expect('PipO'.underscore).to eq 'pip_o'
      expect('Pipo'.underscore).to eq 'pipo'
    end

  end

end
