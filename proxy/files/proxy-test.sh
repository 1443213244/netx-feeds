#!/bin/sh

# 获取参数
PROXY_USER=$1
PROXY_PASS=$2
REMOTE_PORT=$3
REMOTE_ADDR=$4

# 检查并清理占用1080端口的旧进程
cleanOldProcess() {
    OLD_PROXY_PID=$(netstat -npl 2>/dev/null | grep :1080 | awk '{print $7}' | cut -d'/' -f1 | uniq)
    if [ -n "$OLD_PROXY_PID" ]; then
        kill -9 $OLD_PROXY_PID >/dev/null 2>&1 || true
        echo "已清理占用1080端口的旧进程"
    else
        echo "1080端口无旧进程占用"
    fi
}

# 添加iptables规则
addIptablesRules() {
    iptables -t mangle -I GOST_LOCAL -p tcp --dport $REMOTE_PORT -j ACCEPT
    iptables -t mangle -I GOST_LOCAL -p tcp --dport $REMOTE_PORT -j RETURN
    echo "已添加iptables规则"
}

# 启动Proxy并获取其PID
startProxyAndGetPid() {
    proxy -L :1080 -F relay+mtls://$PROXY_USER:$PROXY_PASS@$REMOTE_ADDR:$REMOTE_PORT >/dev/null 2>&1 &
    PROXY_PID=$!
    echo "已启动Proxy，进程ID是: $PROXY_PID"
}

# 测试代理是否正常
testProxy() {
    TEST_URL="http://httpbin.org/ip"  # 更改为你要测试的网站地址
    sleep 5
    if curl -x socks5://127.0.0.1:1080 -m 10 $TEST_URL >/dev/null 2>&1; then
        echo "代理测试成功"
    else
        echo "代理测试失败"
    fi
}

# 删除iptables规则并尝试杀死Proxy进程
cleanIptablesAndKillProxy() {
    iptables -t mangle -D GOST_LOCAL -p tcp --dport $REMOTE_PORT -j ACCEPT
    iptables -t mangle -D GOST_LOCAL -p tcp --dport $REMOTE_PORT -j RETURN
    echo "已删除iptables规则"
    if kill $PROXY_PID >/dev/null 2>&1; then
        echo "已结束Proxy进程"
    else
        echo "结束Proxy进程失败"
    fi
}

# 将上述函数组合起来
cleanOldProcess
addIptablesRules
startProxyAndGetPid
testProxy
cleanIptablesAndKillProxy