#!/bin/bash

# --- Configurações ---
source_repo_user="fidelissauro"
target_repo_user="zenardi"
source_repo="chip"

echo ">>> Iniciando processo de migração..."

# 1. Busca dinâmica das tags (Requer 'jq' instalado)
echo "Consultando Docker Hub..."
tags_list=$(curl -L -s "https://registry.hub.docker.com/v2/repositories/${source_repo_user}/${source_repo}/tags?page_size=100" | jq -r '.results[].name')

# Verifica se a lista não está vazia
if [ -z "$tags_list" ]; then
    echo "ERRO: Nenhuma tag encontrada. Verifique o nome do repositório ou se o 'jq' está instalado."
    exit 1
fi

echo "Tags encontradas e prontas para processar."
echo "------------------------------------------"

# --- FASE 1: Clonagem (Pull -> Tag -> Push) ---
# Aqui aproveitamos o cache. Se as tags compartilham base, o download será super rápido.
echo ">>> FASE 1: Baixando e Enviando (Mantendo cache local)..."

for tag in $tags_list; do
    echo "--- Processando tag: $tag ---"
    
    # Download
    docker pull $source_repo_user/$source_repo:$tag
    
    # Renomeação
    docker tag $source_repo_user/$source_repo:$tag $target_repo_user/$source_repo:$tag
    
    # Upload
    docker push $target_repo_user/$source_repo:$tag
done

echo ">>> FASE 1 Concluída com sucesso."
echo ""

# --- FASE 2: Limpeza (RMI) ---
# Agora que tudo foi enviado, limpamos tudo de uma vez.
echo ">>> FASE 2: Limpeza de disco (Removendo imagens locais)..."

for tag in $tags_list; do
    echo "Removendo tag: $tag"
    docker rmi $target_repo_user/$source_repo:$tag
    docker rmi $source_repo_user/$source_repo:$tag
done

echo ""
echo ">>> MIGRACAO COMPLETA! <<<"