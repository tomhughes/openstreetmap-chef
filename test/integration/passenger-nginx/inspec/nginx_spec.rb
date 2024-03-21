describe package("nginx") do
  it { should be_installed }
end

describe service("nginx") do
  it { should be_enabled }
  it { should be_running }
end

describe port(8050) do
  it { should be_listening }
  its("protocols") { should cmp "tcp" }
end
