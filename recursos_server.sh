#!/bin/bash

ARQUIVO="/var/www/recursos.txt"

echo "==================================================" > "$ARQUIVO"
echo "RELATÓRIO DE RECURSOS DO SERVIDOR - $(date)" >> "$ARQUIVO"
echo "==================================================" >> "$ARQUIVO"
echo "" >> "$ARQUIVO"

# Uso de RAM
TOTAL_RAM=$(free -m | awk '/^Mem:/ {print $2}')
USADA_RAM=$(free -m | awk '/^Mem:/ {print $3}')
LIVRE_RAM=$((TOTAL_RAM - USADA_RAM))
PORCENT_RAM=$((USADA_RAM * 100 / TOTAL_RAM))

echo "🧠 USO DE MEMÓRIA RAM:" >> "$ARQUIVO"
echo "Total: ${TOTAL_RAM} MB" >> "$ARQUIVO"
echo "Usada: ${USADA_RAM} MB (${PORCENT_RAM}%)" >> "$ARQUIVO"
echo "Livre: ${LIVRE_RAM} MB" >> "$ARQUIVO"
echo "" >> "$ARQUIVO"

# Espaço em Disco em /var/www
DISCO_TOTAL=$(df -h /var/www | awk 'NR==2 {print $2}')
DISCO_USADO=$(df -h /var/www | awk 'NR==2 {print $3}')
DISCO_DISP=$(df -h /var/www | awk 'NR==2 {print $4}')
DISCO_PORCENT=$(df -h /var/www | awk 'NR==2 {print $5}')

echo "💾 USO DE DISCO EM /var/www:" >> "$ARQUIVO"
echo "Total: $DISCO_TOTAL" >> "$ARQUIVO"
echo "Usado: $DISCO_USADO ($DISCO_PORCENT)" >> "$ARQUIVO"
echo "Disponível: $DISCO_DISP" >> "$ARQUIVO"
echo "" >> "$ARQUIVO"

# Load Average
LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | sed 's/^ //')
LOAD_1=$(echo $LOAD | cut -d',' -f1)
LOAD_5=$(echo $LOAD | cut -d',' -f2)
LOAD_15=$(echo $LOAD | cut -d',' -f3)
CPU_CORES=$(nproc)

echo "⚙️ CARGA DO PROCESSADOR (Load Average):" >> "$ARQUIVO"
echo "1 minuto: $LOAD_1" >> "$ARQUIVO"
echo "5 minutos: $LOAD_5" >> "$ARQUIVO"
echo "15 minutos: $LOAD_15" >> "$ARQUIVO"
echo "Núcleos de CPU disponíveis: $CPU_CORES" >> "$ARQUIVO"
echo "" >> "$ARQUIVO"

# Diagnóstico
echo "🔎 DIAGNÓSTICO SIMPLIFICADO:" >> "$ARQUIVO"

# RAM
if [ "$PORCENT_RAM" -lt 70 ]; then
    echo "- RAM: OK. Há memória suficiente disponível." >> "$ARQUIVO"
elif [ "$PORCENT_RAM" -lt 90 ]; then
    echo "- RAM: ALERTA. Memória começando a ficar sobrecarregada." >> "$ARQUIVO"
else
    echo "- RAM: CRÍTICO. A memória está quase cheia, isso pode afetar os sites." >> "$ARQUIVO"
fi

# DISCO
DISCO_PORCENT_NUM=$(echo $DISCO_PORCENT | tr -d '%')
if [ "$DISCO_PORCENT_NUM" -lt 70 ]; then
    echo "- DISCO: OK. Há bastante espaço livre." >> "$ARQUIVO"
elif [ "$DISCO_PORCENT_NUM" -lt 90 ]; then
    echo "- DISCO: ALERTA. O espaço está sendo consumido rapidamente." >> "$ARQUIVO"
else
    echo "- DISCO: CRÍTICO. Pouco espaço restante, risco de travamento." >> "$ARQUIVO"
fi

# LOAD
LOAD_1_INT=$(printf "%.0f" "$LOAD_1")
if [ "$LOAD_1_INT" -lt "$CPU_CORES" ]; then
    echo "- PROCESSADOR: OK. A carga está dentro do normal." >> "$ARQUIVO"
elif [ "$LOAD_1_INT" -lt $((CPU_CORES + 2)) ]; then
    echo "- PROCESSADOR: ALERTA. O servidor está trabalhando no limite." >> "$ARQUIVO"
else
    echo "- PROCESSADOR: CRÍTICO. A carga está muito alta, possível lentidão nos sites." >> "$ARQUIVO"
fi

echo "" >> "$ARQUIVO"
echo "Relatório finalizado e salvo em: $ARQUIVO"
