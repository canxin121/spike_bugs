## rocket_emulator

https://github.com/chipsalliance/rocket-chip, commit f517abbf41abb65cea37421d3559f9739efd00a9, with config below: 

```scala
class MaxExtensionRV64Config extends Config(
  new WithB ++           
  new WithFP16 ++        
  new WithHypervisor ++  
  new DefaultConfig      
)

class MaxExtensionRV32Config extends Config(
  new WithB ++           
  new WithFP16 ++        
  new WithHypervisor ++  
  new WithRV32 ++        
  new WithNBigCores(1) ++ 
  new WithCoherentBusTopology ++ 
  new BaseConfig
)
```