name "dribble"
description "Master role applied to dribble"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.4"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      },
      :external => {
        :interface => "bond0.3",
        :role => :external,
        :inet => {
          :address => "184.104.179.132"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::4"
        }
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :effective_cache_size => "350GB"
      }
    }
  }
)

run_list(
  "role[equinix-ams]",
  "role[vectortile]"
)
