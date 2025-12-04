Host bastion
  HostName ${bastion_ip}
  User ubuntu
  IdentityFile ~/.ssh/bastion.pem

%{ for i in range(count) ~}
Host private-${i+1}
  HostName 10.0.${i+2}.10
  User ubuntu
  ProxyJump bastion
  IdentityFile ~/.ssh/private-${i+1}.pem
%{ endfor ~}