import json

INPUT_FILE  = r'C:\Users\vitor\Documents\HairSense\database\openbeautyfacts-products.jsonl'
OUTPUT_FILE = r'C:\Users\vitor\Documents\HairSense\database\base_produtos.json'

def jsonl_to_json(input_path: str, output_path: str):
    """
    Converte um arquivo JSONL em um único JSON array.
    Usa escrita em streaming para não carregar tudo na memória.
    """
    with open(input_path, 'r', encoding='utf-8') as fin, \
         open(output_path, 'w', encoding='utf-8') as fout:

        fout.write('[\n')
        first = True

        for line in fin:
            line = line.strip()
            if not line:
                continue

            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                continue

            if not first:
                fout.write(',\n')
            else:
                first = False

            json.dump(record, fout, ensure_ascii=False)

        fout.write('\n]')

    print(f'Conversão concluída: {output_path}')

if __name__ == '__main__':
    jsonl_to_json(INPUT_FILE, OUTPUT_FILE)