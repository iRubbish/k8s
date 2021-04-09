#!/bin/bash
#创建auth,此auth主要是让longhorn更安全，访问的时候需要输入一个密码。这里创建了一个root账号，密码123456
USER=root; PASSWORD=123456; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" >> auth
#在longhorn-system中创建一个secret
kubectl -n longhorn-system create secret generic basic-auth --from-file=auth
#生成私钥
(umask 077;openssl genrsa -out tls.key 2048)
#生成证书，/CN后的域名是你要访问的域名这个不能填错也是一个必填字段，如果填错了访问的时候会无法访问。其他参数自行百度，与字段非必须。
openssl req -new -x509 -key tls.key -out tls.crt -subj "/CN=www.ik8s.io" -days 365
#创建secret,这里我直接使用命令行创建.在longhorn-system命名空间中创建一个名为longhorn-tls的secret。
kubectl -n longhorn-system  create secret tls longhorn-tls  --cert=./tls.crt --key=./tls.key
#准备好上面的工作后，咱们创建一个ingress
echo "
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: longhorn-ingress
  namespace: longhorn-system
  annotations:
    # type of authentication
    nginx.ingress.kubernetes.io/auth-type: basic
    # prevent the controller from redirecting (308) to HTTPS
    nginx.ingress.kubernetes.io/ssl-redirect: 'false'
    # name of the secret that contains the user/password definitions
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    # message to display with an appropriate context why the authentication is required
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required '
spec:
  rules:
  - host: www.longhorn.bo    #配置访问域名，也就是常说的虚拟主机。这里的host与hosts需保持一致性哈。
    http:
      paths:
      - path: /
        backend:
          serviceName: longhorn-frontend
          servicePort: 80
  tls:   #配置https协议
  - hosts:
    - www.longhorn.bo    #配置访问域名，也就是常说的虚拟主机
    secretName: longhorn-tls     #绑定secretName
" | kubectl apply -f -
