# proxy-config-script.sh

generate_proxy_config() {
    PROXY_CONFIG_FILE="/tmp/proxy.yaml"
    proxy=$(uci show proxy | grep -oE '^proxy\.@proxy\[[0-9]+\]' | sort -u | wc -l)

    # 清空已有的配置文件
    echo "services:" > "$PROXY_CONFIG_FILE"

    # 写 services
    for i in $(seq 0 $((proxy - 1))); do
        port=$(uci get proxy.@proxy[$i].port)
        ip=$(uci get proxy.@proxy[$i].ip)
        username=$(uci get proxy.@proxy[$i].username)
        password=$(uci get proxy.@proxy[$i].password)

        echo "- name: service-$i" >> "$PROXY_CONFIG_FILE"
        echo "  addr: :$port" >> "$PROXY_CONFIG_FILE"
        echo "  handler:" >> "$PROXY_CONFIG_FILE"
        echo "    type: relay" >> "$PROXY_CONFIG_FILE"
        echo "    chain: chain-$i" >> "$PROXY_CONFIG_FILE"
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
    for i in $(seq 0 $((proxy - 1))); do
        port=$(uci get proxy.@proxy[$i].port)
        ip=$(uci get proxy.@proxy[$i].ip)
        username=$(uci get proxy.@proxy[$i].username)
        password=$(uci get proxy.@proxy[$i].password)

        echo "- name: chain-$i" >> "$PROXY_CONFIG_FILE"
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
