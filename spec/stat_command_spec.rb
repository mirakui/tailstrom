require 'spec_helper'

describe 'stat' do
  def run(options)
    `bin/tailstrom #{options} spec/fixtures/log-01.txt`
  end

  it { expect(run '-f2').to eq <<-END }
---------------------------------------------------
  count        min        max        avg key       
---------------------------------------------------
    300      1,521    995,595    468,164 -         
END

  it { expect(run '-f2 -k0').to eq <<-END }
---------------------------------------------------
  count        min        max        avg key       
---------------------------------------------------
    161      2,524    995,595    460,966 302       
    139      1,521    958,131    476,502 200       
END

  it { expect(run '-f2 -k3 --map key=key[/[a-z]+/]').to eq <<-END }
---------------------------------------------------
  count        min        max        avg key       
---------------------------------------------------
    104      2,524    995,595    505,832 products  
     93      5,584    971,226    485,544 users     
    103      1,521    989,278    414,438 photos    
END

end
