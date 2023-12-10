# IPv6 довольно молодой и дырявый протокол, лишних проблем с его настройками нам не надо, как и лишних угроз.
# Проверка ядра
[ -f /proc/net/if_inet6 ] && echo 'IPv6 ready system!'
# Вывод интерфейсов с включенной поддержкой IPv6
ip -o -6 addr
# Проверяем IP Forwarding (не роутер же у нас, а просто сервер…)
if grep -q -P "^\s*net\.ipv4\.ip_forward\s*=\s*1\s*$" /etc/sysctl.conf; then echo "IP Forwarding enabled"; fi
# Но одно дело в конфиге, другое дело в памяти. Так даже будет надежнее. В конфиге может быть ничего не указано, а в памяти есть все текущие настройки:
if ! grep -q -P "^\s*0\s*$" /proc/sys/net/ipv4/ip_forward; then echo "IP Forwarding enabled"; fi
# Проверяем поддержку маршрутизации от источника (проверяем сразу для all и default и сразу в памяти)
if (! (grep -q -P "^\s*0\s*$" /proc/sys/net/ipv4/conf/all/accept_source_route && grep -q -P "^\s*0\s*$" /proc/sys/net/ipv4/conf/default/accept_source_route)); then echo "Source routing enabled"; fi
# net.ipv4.conf.(all|default).accept_redirects - ставим 0, игнорируем ICMP редиректы, так как не хотим, чтобы маршрут мог быть изменен.
# net.ipv4.icmp_echo_ignore_broadcasts - ставим 1, кому нужны широковещательные пинги в 21 веке?
# net.ipv4.icmp_ignore_bogus_error_messages - зачем нам разбирать кривые ICMP пакеты? Что там может быть хорошего, только логи засорять. В топку!
# net.ipv4.tcp_syncookies - тут надо ставить 1. Классическая защита от SynFlood атак, лишней не будет 8).
# net.ipv4.conf.(all|default).rp_filter - тут конечно 1. Верификация IP источника, полезная фича для защиты IP Spoofing атак
# локальные правила фильтрации
if (iptables -S|grep -P "^\-P\s+((INPUT)|(FORWARD)|(OUTPUT))\s+ACCEPT$"); then echo "Your firewall suck"; fi
