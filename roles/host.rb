description "Linux-VServer Hosts"

run_list(%w(
  role[base]
  recipe[mdadm]
  recipe[ntp]
  recipe[pkgsync]
  recipe[shorewall]
  recipe[smart]
  recipe[vserver]
))

default_attributes({
  "munin" => {
    "group" => "hosts"
  },
})
