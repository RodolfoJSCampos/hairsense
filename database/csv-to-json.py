import csv
import json
from datetime import datetime

def csv_para_json(caminho_csv, caminho_json):
    dados = []

    with open(caminho_csv, mode='r', encoding='utf-8') as f:
        leitor = csv.DictReader(f)

        for linha in leitor:
            # Limpeza de espaços em branco e normalização de valores
            item = {chave.strip(): valor.strip() for chave, valor in linha.items()}

            # Dividir múltiplos CAS No em lista
            item["CAS No"] = [cas.strip() for cas in item["CAS No"].split(',') if cas.strip()]

            # Dividir múltiplas funções
            item["Function"] = [func.strip() for func in item["Function"].split(',') if func.strip()]

            # Converter data para formato ISO (opcional)
            try:
                item["Update Date"] = datetime.strptime(item["Update Date"], "%d/%m/%Y").date().isoformat()
            except Exception:
                pass  # Mantém original se falhar

            dados.append(item)

    # Salvar como JSON
    with open(caminho_json, mode='w', encoding='utf-8') as f:
        json.dump(dados, f, ensure_ascii=False, indent=4)

    print(f"✅ Arquivo JSON salvo em: {caminho_json}")

# Exemplo de uso
csv_para_json("cosing_data.csv", "cosing_dados.json")
