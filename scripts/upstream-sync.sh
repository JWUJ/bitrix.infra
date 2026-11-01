#!/usr/bin/env bash
# Upstream Synchronization Helper for bitrix.infra (Bash / Linux)
set -eo pipefail

echo -e "\033[36m=== Проверка синхронизации с paskal/bitrix.infra ===\033[0m"

echo -e "\n\033[33m[1/3] Загрузка данных из upstream...\033[0m"
git fetch upstream || echo -e "\033[31mОшибка git fetch upstream\033[0m"

# Зеркалирование upstream-master
git branch -f upstream-master upstream/master 2>/dev/null || true

BEHIND=$(git rev-list --count master..upstream/master 2>/dev/null || echo 0)
AHEAD=$(git rev-list --count upstream/master..master 2>/dev/null || echo 0)

echo -e "\n\033[36m[2/3] Статус веток:\033[0m"
echo -e "  Новых коммитов в upstream: \033[33m${BEHIND}\033[0m"
echo -e "  Локальных коммитов в master: \033[37m${AHEAD}\033[0m"

if [ "${BEHIND}" -gt 0 ]; then
    echo -e "\n\033[32m[3/3] Свежие коммиты в upstream/master:\033[0m"
    git log master..upstream/master --oneline --decorate -n 20
    echo -e "\n\033[36mИнтеграция:\033[0m"
    echo -e "  Точечный коммит: git cherry-pick <hash>"
    echo -e "  Пакетное слияние: git checkout -b sync/upstream-\$(date +%Y-%m-%d) && git merge upstream/master"
else
    echo -e "\n\033[32mРепозиторий актуален!\033[0m"
fi
