#!/bin/sh

# 获取参数
PROXY_USER=$1
PROXY_PASS=$2
REMOTE_PORT=$3
REMOTE_ADDR=$4
LOCAL_ADDR="0.0.0.0"  # 替换为你的本地地址

# 添加 iptables 规则到 GOST_LOCAL 链
iptables -t mangle -I GOST_LOCAL -p tcp --dport $REMOTE_PORT -j ACCEPT
iptables -t mangle -I GOST_LOCAL -p tcp --dport $REMOTE_PORT -j RETURN

# 启动 Proxy 代理，并获取进程编号
proxy -L :1080 -F relay+mtls://$PROXY_USER:$PROXY_PASS@$REMOTE_ADDR:$REMOTE_PORT >/dev/null 2>&1 &
PROXY_PID=$!

# 等待一段时间，确保代理连接远程服务的过程有足够的时间完成
sleep 1

# 测试代理是否正常
TEST_URL="http://httpbin.org/ip"  # 替换成你要测试的网站

# 使用 curl 测试代理
if curl -x socks5://127.0.0.1:1080 -m 10 $TEST_URL >/dev/null 2>&1; then
    echo "true"
else
    echo "false"
fi

# 删除 iptables 规则
iptables -t mangle -D GOST_LOCAL -p tcp --dport $REMOTE_PORT -j ACCEPT
iptables -t mangle -D GOST_LOCAL -p tcp --dport $REMOTE_PORT -j RETURN

# 杀死 Proxy 进程
kill $PROXY_PID >/dev/null 2>&1