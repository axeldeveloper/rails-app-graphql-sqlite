#!/bin/bash
set -e

# echo "Instalando dependencias do nodejs para front."
# yarn install

# Adicione esta linha para instalar o Rubocop no contêiner
echo "Instalar o Rubocop no contêiner"
#gem install rubocop rubocop-rails


#rm -f /myapp/tmp/pids/server.pid

# Verifica se há migrações pendentes e as executa
echo "Verificando e aplicando migrações pendentes..."

# Verifica se há migrações pendentes
if rails db:migrate:status | grep -q "down"; then
  echo "Existem migrações pendentes. Executando..."
  # Executa as migrações pendentes
  rails db:migrate
else
  echo "Nenhuma migração pendente."
fi


# RUN MAIN PROCESS
exec "$@"