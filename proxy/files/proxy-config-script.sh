# proxy-config-script.sh

generate_proxy_config() {
    PROXY_CONFIG_FILE="/tmp/proxy.yaml"
    proxy_names=$(uci show proxy | grep -oE 'proxy\.[^=]+' | cut -d'.' -f2 | sort -u)

    # 清空已有的配置文件
    echo "services:" > "$PROXY_CONFIG_FILE"

    # 写 services
    for name in $proxy_names; do
        port=$(uci get proxy.$name.port)
        ip=$(uci get proxy.$name.ip)
        local_port=$(uci get proxy.$name.local_port)
        username=$(uci get proxy.$name.username)
        password=$(uci get proxy.$name.password)

        echo "- name: $name" >> "$PROXY_CONFIG_FILE"
        echo "  addr: :$local_port" >> "$PROXY_CONFIG_FILE"
        echo "  handler:" >> "$PROXY_CONFIG_FILE"
        echo "    type: red" >> "$PROXY_CONFIG_FILE"
        echo "    chain: chain-$name" >> "$PROXY_CONFIG_FILE"
        echo "    metadata:" >> "$PROXY_CONFIG_FILE"
        echo "      sniffing: true" >> "$PROXY_CONFIG_FILE"
        echo "      tproxy: true" >> "$PROXY_CONFIG_FILE"
        echo "  listener:" >> "$PROXY_CONFIG_FILE"
        echo "    type: red" >> "$PROXY_CONFIG_FILE"
        echo "    metadata:" >> "$PROXY_CONFIG_FILE"
        echo "      tproxy: true" >> "$PROXY_CONFIG_FILE"
    done

    echo "chains:" >> "$PROXY_CONFIG_FILE"
    # 写 chains
    for name in $proxy_names; do
        port=$(uci get proxy.$name.port)
        ip=$(uci get proxy.$name.ip)
        username=$(uci get proxy.$name.username)
        password=$(uci get proxy.$name.password)

        echo "- name: chain-$name" >> "$PROXY_CONFIG_FILE"
        echo "  hops:" >> "$PROXY_CONFIG_FILE"
        echo "    - name: hop-0" >> "$PROXY_CONFIG_FILE"
        echo "      sockopts:" >> "$PROXY_CONFIG_FILE"
        echo "        mark: 100" >> "$PROXY_CONFIG_FILE"
        echo "      nodes:" >> "$PROXY_CONFIG_FILE"
        echo "        - name: node-0" >> "$PROXY_CONFIG_FILE"
        echo "          addr: $ip:$port" >> "$PROXY_CONFIG_FILE"
        echo "          connector:" >> "$PROXY_CONFIG_FILE"
        echo "            type: relay" >> "$PROXY_CONFIG_FILE"
        echo "            auth:" >> "$PROXY_CONFIG_FILE"
        echo "              username: $username" >> "$PROXY_CONFIG_FILE"
        echo "              password: $password" >> "$PROXY_CONFIG_FILE"
        echo "          dialer:" >> "$PROXY_CONFIG_FILE"
        echo "            type: mtls" >> "$PROXY_CONFIG_FILE"
    done
}

# 调用生成 PROXY 配置文件的函数
generate_proxy_config
